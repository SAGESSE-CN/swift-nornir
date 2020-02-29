//
//  SAMAudioPlayer.swift
//  SAMedia
//
//  Created by SAGESSE on 27/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation

///
/// 音频播放器
/// TODO: 支持网络文件
///
@objc open class SAMAudioPlayer: NSObject, AVAudioPlayerDelegate {

    // data must be in the form of an audio file understood by CoreAudio
    public init(contentsOf url: URL) throws {
        super.init()
        self.avplayer = try AVAudioPlayer(contentsOf: url)
        self.addObservers()
    }

    public init(data: Data) throws {
        super.init()
        self.avplayer = try AVAudioPlayer(data: data)
        self.addObservers()
    }

    // The file type hint is a constant defined in AVMediaFormat.h whose value is a UTI for a file format. e.g. AVFileTypeAIFF.
    // Sometimes the type of a file cannot be determined from the data, or it is actually corrupt.
    // The file type hint tells the parser what kind of data to look for so that files which are not self identifying or possibly even corrupt can be successfully parsed.
    public init(contentsOf url: URL, fileTypeHint utiString: String?) throws {
        super.init()
        self.avplayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: utiString)
        self.addObservers()
    }
    
    public init(data: Data, fileTypeHint utiString: String?) throws {
        super.init()
        self.avplayer = try AVAudioPlayer(data: data, fileTypeHint: utiString)
        self.addObservers()
    }
    
    deinit {
        // must clear delegate, otherwise it will also present memory access exceptions.
        self.avplayer.delegate = nil
        self.stop()
        self.removeObservers()
    }
    
    // MARK: - Transport Control
    
    // methods that return BOOL return YES on success and NO on failure.
    // get ready to play the sound. happens automatically on play.
    @discardableResult
    open func prepareToPlay() -> Bool  {
        return performForPrepare(with: nil)
    }
    
    // sound is played asynchronously.
    @discardableResult
    open func play() -> Bool {
        return performForPlay {
            self.avplayer.play()
        }
    }
    // play a sound some time in the future. time is an absolute time based on and greater than deviceCurrentTime.
    @discardableResult
    open func play(at time: TimeInterval) -> Bool {
        return performForPlay {
            self.avplayer.play(atTime: time)
        }
    }
    
    // pauses playback, but remains ready to play.
    open func pause() {
        
        // if there is playing, pause it
        if _isPlaying {
            _isPlaying = false
            
            avplayer.pause()
            delegate?.audioPlayer?(didPause: self)
        }
        // must be restored to session
        deactive()
    }
    // stops playback. no longer ready to play.
    open func stop() {
        
        // if there is playing, stop it
        if _isPrepared  {
            _isPlaying = false
            _isPrepared = false
            
            avplayer.stop()
            delegate?.audioPlayer?(didStop: self)
        }
        // must be restored to session
        deactive()
    }
 
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionDidInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func performForPrepare(with handler: ((Bool) -> Bool)?) -> Bool {
        // is preared?
        guard !_isPrepared else {
            return handler?(_isPrepared) ?? true
        }
        guard delegate?.audioPlayer?(shouldPreparing: self) ?? true else {
            return false // reject
        }
        // TODO: 如果是异步资源, 那下载好再播放
        
        guard active() else {
            return false // can't active
        }
        guard avplayer.prepareToPlay() else {
            return deactive() && false // error
        }
        _isPrepared = true
        avplayer.delegate = self
        avplayer.currentTime = 0
        
        delegate?.audioPlayer?(didPreparing: self)
        
        return handler?(_isPrepared) ?? true
    }
    
    fileprivate func performForPlay(with handler: @escaping () -> Bool) -> Bool {
        guard !_isPlaying else {
            return true
        }
        // if there is no prepare, call prepareToPlay
        return performForPrepare { isPrepared in
            
            guard isPrepared else {
                return false
            }
            guard self.active() else {
                return false
            }
            guard self.delegate?.audioPlayer?(shouldPlaying: self) ?? true else {
                return self.deactive() && false // reject
            }
            guard handler() else {
                return self.deactive() && false
            }
            self._isPlaying = true
            
            self.delegate?.audioPlayer?(didPlaying: self)
            
            return true
        }
    }
    
    
    @discardableResult
    fileprivate func active() -> Bool {
        guard !_isActived else {
            return true
        }
        _isActived = true
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().sm_setActive(true, context: self)
            return true
        } catch {
            return false
        }
        
    }
    @discardableResult
    fileprivate func deactive() -> Bool {
        guard _isActived else {
            return true
        }
        _isActived = false
        do {
            try AVAudioSession.sharedInstance().sm_setActive(false, with: .notifyOthersOnDeactivation, context: self)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Properties

    // is it playing or not?
    open var isPlaying: Bool {
        return avplayer.isPlaying
    }
    
    // returns nil if object was not created with a URL
    open var url: URL? {
        return avplayer.url
    }
    
    // returns nil if object was not created with a data object
    open var data: Data? {
        return avplayer.data
    }

    // the duration of the sound.
    open var duration: TimeInterval {
        return avplayer.duration
    }
    
    // If the sound is playing, currentTime is the offset into the sound of the current playback position.
    // If the sound is not playing, currentTime is the offset into the sound where playing would start.
    open var currentTime: TimeInterval {
        set { return avplayer.currentTime = newValue }
        get { return avplayer.currentTime }
    }
    
    // returns the current time associated with the output device
    open var deviceCurrentTime: TimeInterval {
        return avplayer.deviceCurrentTime
    }
    
    // "numberOfLoops" is the number of times that the sound will return to the beginning upon reaching the end.
    // A value of zero means to play the sound just once.
    // A value of one will result in playing the sound twice, and so on..
    // Any negative number will loop indefinitely until stopped.
    open var numberOfLoops: Int {
        set { return avplayer.numberOfLoops = newValue }
        get { return avplayer.numberOfLoops }
    }
    
    open var numberOfChannels: Int {
        return avplayer.numberOfChannels
    }
    
    // the delegate will be sent messages from the SAMAudioPlayerDelegate protocol
    open weak var delegate: SAMAudioPlayerDelegate?
    
    // set panning. -1.0 is left, 0.0 is center, 1.0 is right.
    open var pan: Float  {
        set { return avplayer.pan = newValue }
        get { return avplayer.pan }
    }

    // The volume for the sound. The nominal range is from 0.0 to 1.0.
    open var volume: Float  {
        set { return avplayer.volume = newValue }
        get { return avplayer.volume }
    }
    
    // You must set enableRate to YES for the rate property to take effect. You must set this before calling prepareToPlay.
    open var enableRate: Bool {
        set { return avplayer.enableRate = newValue }
        get { return avplayer.enableRate }
    }
    
    // See enableRate. The playback rate for the sound. 1.0 is normal, 0.5 is half speed, 2.0 is double speed.
    open var rate: Float  {
        set { return avplayer.rate = newValue }
        get { return avplayer.rate }
    }
    
    // returns a settings dictionary with keys as described in AVAudioSettings.h
    open var settings: [String : Any] {
        return avplayer.settings
    } 
    
    
    // MARK: - Metering
    
    
    // turns level metering on or off. default is off.
    open var isMeteringEnabled: Bool {
        set { return avplayer.isMeteringEnabled = newValue }
        get { return avplayer.isMeteringEnabled }
    }
    
    // call to refresh meter values
    open func updateMeters()  {
        return avplayer.updateMeters()
    }
    
    // returns peak power in decibels for a given channel
    open func peakPower(forChannel channelNumber: Int) -> Float  {
        return avplayer.peakPower(forChannel: channelNumber)
    }
    
    // returns average power in decibels for a given channel
    open func averagePower(forChannel channelNumber: Int) -> Float  {
        return avplayer.averagePower(forChannel: channelNumber)
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    open func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        _isPlaying = false
        _isPrepared = false
        
        deactive()
        delegate?.audioPlayer?(didFinishPlaying: self, successfully: flag)
    }
    
    open func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        _isPlaying = false
        _isPrepared = false
        
        deactive()
        delegate?.audioPlayer?(didOccur: self, error: error)
    }
    
    @objc open func audioSessionDidInterruption(_ sender: Notification) {
        
        _isPlaying = false
        
        deactive()
        delegate?.audioPlayer?(didInterruption: self)
    }
    
    // MARK: - iVar
    
    private var _isPrepared: Bool = false
    private var _isPlaying: Bool = false
    private var _isActived: Bool = false
    
    internal var avplayer: AVAudioPlayer!
}


///
/// 音频播放器代理
///
@objc public protocol SAMAudioPlayerDelegate {

    @objc optional func audioPlayer(shouldPreparing audioPlayer: SAMAudioPlayer) -> Bool
    @objc optional func audioPlayer(didPreparing audioPlayer: SAMAudioPlayer)
    
    @objc optional func audioPlayer(shouldPlaying audioPlayer: SAMAudioPlayer) -> Bool
    @objc optional func audioPlayer(didPlaying audioPlayer: SAMAudioPlayer)
    
    @objc optional func audioPlayer(didPause audioPlayer: SAMAudioPlayer)
    
    @objc optional func audioPlayer(didStop audioPlayer: SAMAudioPlayer)
    @objc optional func audioPlayer(didInterruption audioPlayer: SAMAudioPlayer)
    
    // audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption.
    @objc optional func audioPlayer(didFinishPlaying audioPlayer: SAMAudioPlayer, successfully flag: Bool)
    
    // if an error occurs will be reported to the delegate.
    @objc optional func audioPlayer(didOccur audioPlayer: SAMAudioPlayer, error: Error?)
}

//#import "AudioPlayer.h"
//@import AVFoundation;
//@interface AudioPlayer ()
//{
//    BOOL _isPrepare;//播放是否准备成功
//    BOOL _isPlaying;//播放器是否正在播放
//}
//
//@property(nonatomic,strong)AVPlayer *player;
//@property(nonatomic,strong)NSTimer *timer;
//
//@end
//@implementation AudioPlayer
//
//+(AudioPlayer*)sharePlayer
//{
//    
//    static AudioPlayer *player = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//    player = [AudioPlayer new];
//    });
//    return  player;
//    }
//    - (instancetype)init
//    {
//        self = [super init];
//        if (self) {
//            //通知中心
//            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endAction:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//        }
//        return self;
//}
//
//-(void)setPrepareMusicUrl:(NSString*)urlStr
//{
//    
//    if (self.player.currentItem) {
//        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
//    }
//    
//    //创建一个item资源
//    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
//    [item addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
//    [self.player replaceCurrentItemWithPlayerItem:item];
//}
//
//-(void)play
//    {
//        //判断资源是否准备成功
//        if (!_isPrepare) {
//            return;
//        }
//        [self.player play];
//        _isPlaying = YES;
//        //播放时候的图片转动效果
//        //timer初始化
//        if (_timer) {
//            return;
//        }
//        
//        //创建一个timer
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playingAction:) userInfo:nil repeats:YES];
//        
//        
//}
//-(void)pause
//    {
//        if (!_isPlaying) {
//            return;
//        }
//        
//        [self.player pause];
//        _isPlaying = NO;
//        //销毁计时器
//        [_timer invalidate];
//        _timer = nil;
//        
//}
//
//-(void)seekToTime:(float)time
//{
//    
//    //当音乐播放器时间改变时,先暂停后播放
//    [self pause];
//    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) completionHandler:^(BOOL finished) {
//        if (finished) {
//        [self play];
//        }
//        }];
//    
//}
////每隔0.1秒执行一下这个事件
//-(void)playingAction:(id)sender
//{
//    
//    
//    if (self.delegate&&[self.delegate respondsToSelector:@selector(audioplayerPlayWith:Progress:)]) {
//        
//        //获取当前播放歌曲的时间
//        float progress = 1.0 * self.player.currentTime.value / self.player.currentTime.timescale;
//        [self.delegate audioplayerPlayWith:self Progress:progress];
//        
//        
//    }
//    
//}
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    
//    AVPlayerStatus staute = [change[@"new"] integerValue];
//    switch (staute) {
//    case AVPlayerStatusReadyToPlay:
//        NSLog(@"加载成功,可以播放了");
//        _isPrepare = YES;
//        [self play];
//        break;
//    case AVPlayerStatusFailed:
//        NSLog(@"加载失败");
//        break;
//    case AVPlayerStatusUnknown:
//        NSLog(@"资源找不到");
//        break;
//        
//        
//    default:
//        break;
//    }
//    
//    NSLog(@"change:%@",change);
//}
////当一首歌播放结束时会执行下面的方法
//-(void)endAction:(NSNotification *)not
//{
//    
//    if (self.delegate &&[self.delegate respondsToSelector:@selector(audioplayerDidFinishItem:)]) {
//        [self.delegate audioplayerDidFinishItem:self];
//    }
//    
//}
//
//-(AVPlayer*)player
//    {
//        if (_player==nil) {
//            _player = [AVPlayer new];
//        }
//        return _player;
//}
//
//-(BOOL)isPlaying{
//    return _isPlaying;
//}
//@end
