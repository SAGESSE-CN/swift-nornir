//
//  AppDelegate.swift
//  SIMChatExample
//
//  Created by sagesse on 2/2/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import SIMChat

public func xxxxxx() {
}

let dic = [
    "阿": ["ā", "ē"],
    "挨": ["āi", "ái"],
    "拗": ["ào", "niǜ"],
    "扒": ["bā", "pá"],
    "把": ["bǎ", "bà"],
    "蚌": ["bàng", "bèng"],
    "薄": ["báo", "bó"],
    "堡": ["bǎo", "bǔ", "pù"],
    "暴": ["bào", "pù"],
    "背": ["bèi", "bēi"],
    "奔": ["bēn", "bèn"],
    "臂": ["bì", "bei"],
    "辟": ["bì", "pì"],
    "扁": ["biǎn", "piān"],
    "便": ["biàn", "pián"],
    "骠": ["biāo", "piào"],
    "屏": ["píng", "bǐng"],
    "剥": ["bō", "bāo"],
    "泊": ["bó", "pō"],
    "伯": ["bó", "bǎi"],
    "簸": ["bǒ", "bò"],
    "膊": ["bó", "bo"],
    "卜": ["bo", "bǔ"],
    "藏": ["cáng", "zàng"],
    "差": ["chā", "chà", "cī"],
    "禅": ["chán", "shàn"],
    "颤": ["chàn", "zhàn"],
    "场": ["chǎng", "cháng"],
    "嘲": ["cháo", "zhāo"],
    "车": ["chē", "jū"],
    "称": ["chèng", "chēng"],
    "澄": ["chéng", "dèng"],
    "匙": ["chí", "shi"],
    "冲": ["chōng", "chòng"],
    "臭": ["chòu", "xiù"],
    "处": ["chǔ", "chù"],
    "畜": ["chù", "xù"],
    "创": ["chuàng", "chuāng"],
    "绰": ["chuò", "chāo"],
    "伺": ["cì", "sì"],
    "枞": ["cōng", "zōng"],
    "攒": ["cuán", "zǎn"],
    "撮": ["cuō", "zuǒ"],
    "综": ["zèng", "zōng"],
    "钻": ["zuān", "zuàn"],
    "柞": ["zuò", "zhà"],
    "作": ["zuō", "zuo"],
    "答": ["dá", "dā"],
    "大": ["dà", "dài"],
    "逮": ["dài", "dǎi"],
    "单": ["dán", "chán", "shàn"],
    "当": ["dāng", "dàng"],
    "倒": ["dǎo", "dào"],
    "提": ["dī", "tí"],
    "得": ["dé", "de", "děi"],
    "的": ["dí", "dì", "de"],
    "都": ["dōu", "dū"],
    "掇": ["duō", "duo"],
    "度": ["duó", "dù"],
    "囤": ["dùn", "tún"],
    "发": ["fà", "fā"],
    "坊": ["fāng", "fáng"],
    "分": ["fēn", "fèn"],
    "缝": ["féng", "fèng"],
    "服": ["fú", "fù"],
    "杆": ["gān", "gǎn"],
    "葛": ["gé", "gě"],
    "革": ["gé", "jí"],
    "合": ["gě", "hé"],
    "给": ["gěi", "jǐ"],
    "更": ["gēng", "gèng"],
    "颈": ["jǐng", "gěng"],
    "供": ["gōng", "gòng"],
    "枸": ["gǒu", "gōu", "jǔ"],
    "估": ["gū", "gù"],
    "骨": ["gū", "gǔ"],
    "谷": ["gǔ", "yù"],
    "冠": ["guān", "guàn"],
    "桧": ["guì", "huì"],
    "过": ["guō", "guò"],
    "虾": ["há", "xiā"],
    "哈": ["hǎ", "hà", "hā"],
    "汗": ["hán", "hàn"],
    "巷": ["hàng", "xiàng"],
    "吭": ["háng", "kēng"],
    "号": ["háo", "hào"],
    "和": ["hé", "hè", "hú", "huó", "huò", "huo"],
    "貉": ["hé", "háo"],
    "喝": ["hē", "hè"],
    "横": ["héng", "hèng"],
    "虹": ["hóng", "jiàng"],
    "划": ["huá", "huà"],
    "晃": ["huǎng", "huàng"],
    "会": ["huì", "kuàì"],
    "混": ["hún", "hùn"],
    "哄": ["hǒng", "hòng"],
    "豁": ["huō", "huò"],
    "奇": ["jī", "qí"],
    "缉": ["jī", "qī"],
    "几": ["jī", "jǐ"],
    "济": ["jǐ", "jì"],
    "纪": ["jǐ", "jì"],
    "偈": ["jì", "jié"],
    "系": ["jì", "xì"],
    "茄": ["jiā", "qié"],
    "夹": ["jiā", "jiá"],
    "假": ["jiǎ", "jià"],
    "间": ["jiān", "jiàn"],
    "将": ["jiāng", "jiàng"],
    "嚼": ["jiáo", "jué"],
    "侥": ["jiǎo", "yáo"],
    "角": ["jiǎo", "jué"],
    "脚": ["jiǎo", "jué"],
    "剿": ["jiǎo", "chāo"],
    "教": ["jiāo", "jiào"],
    "校": ["jiào", "xiào"],
    "解": ["jiě", "jiè", "xiè"],
    "结": ["jiē", "jié"],
    "芥": ["jiè", "gài"],
    "藉": ["jiè", "jí"],
    "矜": ["jīn", "qín"],
    "仅": ["jǐn", "jìn"],
    "劲": ["jìn", "jìng"],
    "龟": ["jūn", "guī", "qiū"],
    "咀": ["jǔ", "zuǐ"],
    "矩": ["jǔ", "ju"],
    "菌": ["jūn", "jùn"],
    "卡": ["kǎ", "qiǎ"],
    "看": ["kān", "kàn"],
    "坷": ["kē", "kě"],
    "壳": ["ké", "qià"],
    "可": ["kě", "kè"],
    "克": ["kè", "kēi"],
    "空": ["kōng", "kòng"],
    "溃": ["kuì", "kui"],
    "蓝": ["lán", "lan"],
    "烙": ["lào", "luò"],
    "勒": ["lè", "lēi"],
    "擂": ["léi", "lèi"],
    "累": ["lèi", "léi", "lěi"],
    "蠡": ["lí", "lǐ"],
    "俩": ["liǎ", "liǎng"],
    "量": ["liáng", "liàng", "liang"],
    "踉": ["liáng", "liàng"],
    "潦": ["liáo", "lǎo"],
    "淋": ["lín", "lìn"],
    "馏": ["liú", "liù"],
    "镏": ["liú", "liù"],
    "碌": ["liù", "lù"],
    "笼": ["lóng", "lǒng"],
    "偻": ["ló", "lǚ"],
    "露": ["lù", "lòu"],
    "捋": ["lǚ", "luō"],
    "绿": ["lǜ", "lù"],
    "络": ["luò", "lào"],
    "落": ["luò", "lào", "là"],
    "脉": ["mò", "mài"],
    "埋": ["mái", "mán"],
    "蔓": ["màn", "wàn"],
    "氓": ["máng", "méng"],
    "蒙": ["méng", "méng", "měng"],
    "眯": ["mí", "mī"],
    "靡": ["mí", "mǐ"],
    "秘": ["bì", "mì", "bèi"],
    "泌": ["mì", "bì"],
    "模": ["mó", "mú"],
    "摩": ["mó", "mā"],
    "缪": ["móu", "miù", "miào"],
    "难": ["nán", "nàn"],
    "宁": ["níng", "nìng"],
    "弄": ["nòng", "lòng"],
    "疟": ["nüè", "yào"],
    "娜": ["nuó", "nà"],
    "排": ["pái", "pǎi"],
    "迫": ["pǎi", "pò"],
    "胖": ["pán", "pàng"],
    "刨": ["páo", "bào"],
    "炮": ["páo", "pào"],
    "喷": ["pēn", "pèn", "pen"],
    "片": ["piàn", "piān"],
    "缥": ["piāo", "piǎo"],
    "撇": ["piē", "piě"],
    "仆": ["pū", "pú"],
    "朴": ["pǔ", "pō", "pò", "piáo"],
    "瀑": ["pù", "bào"],
    "曝": ["pù", "bào"],
    "栖": ["qī", "xī"],
    "蹊": ["qī", "xī"],
    "稽": ["qí", "jī"],
    "荨": ["qián", "xún"],
    "欠": ["qiàn", "qian"],
    "镪": ["qiāng", "qiǎng"],
    "强": ["qiáng", "qiǎng", "jiàng"],
    "悄": ["qiāo", "qiǎo"],
    "翘": ["qiào", "qiáo"],
    "切": ["qiē", "qiè"],
    "趄": ["qiè", "qie", "jū"],
    "亲": ["qīn", "qìng"],
    "曲": ["qū", "qǔ"],
    "雀": ["qùe", "qiao", "qiao"],
    "任": ["rén", "rèn"],
    "散": ["sǎn", "san", "sàn"],
    "丧": ["sāng", "sàng", "sang"],
    "色": ["sè", "shǎi"],
    "塞": ["sè", "sāi", "sài"],
    "煞": ["shā", "shà"],
    "厦": ["shà", "xià"],
    "杉": ["shān", "shā"],
    "苫": ["shàn", "shān"],
    "折": ["shé", "shē", "shé"],
    "舍": ["shě", "shè"],
    "什": ["shén", "shí"],
    "葚": ["shèn", "rèn"],
    "识": ["shí", "zhì"],
    "似": ["shì", "sì"],
    "螫": ["shì", "zhē"],
    "说": ["shuì", "shuō"],
    "数": ["shuò", "shǔ", "shù"],
    "遂": ["suí", "suì"],
    "缩": ["suō", "sù"],
    "沓": ["tà", "ta"],
    "苔": ["tái", "tāi"],
    "调": ["tiáo", "diào"],
    "帖": ["tiē", "ti"],
    "瓦": ["wǎ", "wà"],
    "圩": ["wéi", "xū"],
    "委": ["wēi", "wěi"],
    "尾": ["wěi", "yǐ"],
    "尉": ["wèi", "yù"],
    "乌": ["wū", "wù"],
    "吓": ["xiā", "hè"],
    "鲜": ["xiān", "xiǎn"],
    "纤": ["xiān", "qiàn"],
    "相": ["xiāng", "xiàng"],
    "行": ["xíng", "háng", "hàng", "héng"],
    "省": ["xǐng", "shěng"],
    "宿": ["xiù", "xiǔ", "sù"],
    "削": ["xuē", "xiāo"],
    "血": ["xuè", "xiě"],
    "熏": ["xūn", "xùn"],
    "哑": ["yā", "yǎ"],
    "殷": ["yān", "yīn", "yǐn"],
    "咽": ["yān", "yàn", "yè"],
    "钥": ["yào", "yuè"],
    "叶": ["yè", "xié"],
    "艾": ["yì", "ài"],
    "应": ["yīng", "yìng"],
    "佣": ["yōng", "yòng"],
    "熨": ["yù", "yùn"],
    "与": ["yǔ", "yù"],
    "吁": ["yù", "yū", "xū"],
    "晕": ["yūn", "yùn"],
    "载": ["zǎi", "zài"],
    "择": ["zé", "zhái"],
    "扎": ["zhá", "zhā", "zā"],
    "轧": ["zhá", "yà"],
    "粘": ["zhān", "nián"],
    "涨": ["zhǎng", "zhàng"],
    "着": ["zháo", "zhuó", "zhāo"],
    "正": ["zhēng", "zhèng"],
    "殖": ["zhí", "shi"],
    "中": ["zhōng", "zhòng"],
    "种": ["zhǒng", "zhòng"],
    "轴": ["zhóu", "zhòu"],
    "属": ["zhǔ", "shǔ"],
    "著": ["zhù", "zhe", "zhúo"],
    "转": ["zhuǎn", "zhuàn"],
    "幢": ["zhuàng", "chuáng"]
]


//- (UIDevicePlatform) devicePlatformType
//    {
//        NSString *platform = [self devicePlatform];
//        
//        // The ever mysterious iFPGA
//        if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
//        
//        // iPhone
//        if ([platform isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
//        if ([platform isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
//        if ([platform hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
//        if ([platform hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
//        if ([platform hasPrefix:@"iPhone4"])            return UIDevice4SiPhone;
//        
//        if ([platform isEqualToString:@"iPhone5,1"] || [platform isEqualToString:@"iPhone5,2"]) {
//            return UIDevice5iPhone;
//        }
//        if ([platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"]) {
//            return UIDevice5CiPhone;
//        }
//        if ([platform hasPrefix:@"iPhone6"]) {
//            return UIDevice5SiPhone;
//        }
//        
//        if ([platform isEqualToString:@"iPhone7,1"]) {
//            return UIDevice6PiPhone;
//        }
//        if ([platform isEqualToString:@"iPhone7,2"]) {
//            return UIDevice6iPhone;
//        }
//        if ([platform isEqualToString:@"iPhone8,1"]) {
//            return UIDevice6SiPhone;
//        }
//        if ([platform isEqualToString:@"iPhone8,2"]) {
//            return UIDevice6SPiPhone;
//        }
//        
//        // iPod
//        if ([platform hasPrefix:@"iPod1"])              return UIDevice1GiPod;
//        if ([platform hasPrefix:@"iPod2"])              return UIDevice2GiPod;
//        if ([platform hasPrefix:@"iPod3"])              return UIDevice3GiPod;
//        if ([platform hasPrefix:@"iPod4"])              return UIDevice4GiPod;
//        if ([platform hasPrefix:@"iPod5"])              return UIDevice5GiPod;
//        if ([platform hasPrefix:@"iPod7,1"])            return UIDeviceTouch6GiPod;
//        
//        // iPad
//        if ([platform hasPrefix:@"iPad1"])              return UIDevice1GiPad;
//        if ([platform isEqualToString:@"iPad2,1"] || [platform isEqualToString:@"iPad2,2"] || [platform isEqualToString:@"iPad2,3"] || [platform isEqualToString:@"iPad2,4"]) {
//            return UIDevice2GiPad;
//        }
//        //iPad Mini
//        if ([platform isEqualToString:@"iPad2,5"] || [platform isEqualToString:@"iPad2,6"] || [platform isEqualToString:@"iPad2,7"]) {
//            return UIDeviceMiniiPad;
//        }
//        if ([platform isEqualToString:@"iPad3,1"] || [platform isEqualToString:@"iPad3,2"] || [platform isEqualToString:@"iPad3,3"]) {
//            return UIDevice3GiPad;
//        }
//        if ([platform isEqualToString:@"iPad3,4"] || [platform isEqualToString:@"iPad3,5"] || [platform isEqualToString:@"iPad3,6"]) {
//            return UIDevice4GiPad;
//        }
//        //iPad Air
//        if ([platform isEqualToString:@"iPad4,1"] || [platform isEqualToString:@"iPad4,2"] || [platform isEqualToString:@"iPad4,3"]) {
//            return UIDeviceAiriPad;
//        }
//        //iPad Mini2
//        if ([platform isEqualToString:@"iPad4,4"] || [platform isEqualToString:@"iPad4,5"] || [platform isEqualToString:@"iPad4,6"]) {
//            return UIDeviceMini2iPad;
//        }
//        //iPad Mini3
//        if ([platform isEqualToString:@"iPad4,7"] || [platform isEqualToString:@"iPad4,8"] || [platform isEqualToString:@"iPad4,9"]) {
//            return UIDeviceMini3iPad;
//        }
//        //iPad Mini4
//        if ([platform isEqualToString:@"iPad5,1"] || [platform isEqualToString:@"iPad5,2"]) {
//            return UIDeviceMini4iPad;
//        }
//        //iPad Air2
//        if ([platform hasPrefix:@"iPad5,3"] || [platform isEqualToString:@"iPad5,4"]) {
//            return UIDeviceAir2iPad;
//        }
//        
//        // Apple TV
//        if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
//        if ([platform hasPrefix:@"AppleTV3"])           return UIDeviceAppleTV3;
//        
//        if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
//        if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
//        if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
//        if ([platform hasPrefix:@"AppleTV"])            return UIDeviceUnknownAppleTV;
//        
//        // Simulator thanks Jordan Breeding
//        if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
//        {
//            BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
//            return smallerScreen ? UIDeviceSimulatoriPhone : UIDeviceSimulatoriPad;
//        }
//        
//        return UIDeviceUnknown;
//}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        srand(UInt32(time(nil)))
        
        print(dic.count)
        
        
        //-(BOOL)_canOpenURL:(id)url publicURLsOnly:(BOOL)only;
        //SBSCopyLocalizedApplicationNameForDisplayIdentifier
        
//
//        let ems: [SIMChatBaseEmoticon]? = (NSArray(contentsOfFile: "/Users/sagesse/Desktop/emoji.plist") as? Array<NSDictionary>)?.flatMap{
//            let em = SIMChatBaseEmoticon()
//            em.setValuesForKeysWithDictionary($0 as! [String : AnyObject])
//            return em
//        }
//        
//        let s = "😂😱😭😘😳😒😏😄😔😍😉☺😜😁😝😰😓😚😌😊💪👊👍☝👏✌👎🙏👌👈👉👆👇👀👃👄👂🍚🍝🍜🍙🍧🍣🎂🍞🍔🍳🍟🍺🍻🍸☕🍎🍊🍓🍉💊🚬🎄🌹🎉🌴💝🎀🎈🐚💍💣👑🔔⭐✨💨💦🔥🏆💰💤⚡👣💩💉♨📫🔑🔒✈🚄🚗🚤🚲🐎🚀🚌⛵👩👨👧👦🐵🐙🐷💀🐤🐨🐮🐔🐸👻🐛🐠🐶🐯👼🐧🐳🐭👒👗💄👠👢🌂👜👙👕👟☁☀☔🌙⛄⭕❌❔❕☎📷📱📠💻🎥🎤🔫💿💓♣🀄〽🎰🚥🚧🎸💈🛀🚽🏠⛪🏦🏥🏨🏧🏪🚹🚺".characters
//        let a: Array<Dictionary<String, AnyObject>>?  = s.flatMap { s in
//            if let idx = ems?.indexOf({
//                return $0.name?.characters.contains(s) ?? false
//            }) {
//                return ems![idx].toDictionary()
//            }
//            print(s)
//            return nil
//        }
//
//        print(s.count)
//        print(a?.count)
        
        //ems?.filter {
//            if let n = $0.name?.characters.first {
//                return s.contains(n)
//            }
//            return false
//        }.flatMap {
//            return $0.toDictionary()
//        }
        
        
//
//        let arr = NSArray(contentsOfFile: "/Users/sagesse/Projects/swift-chat/SIMChat/Supporting Files/SIMChat.bundle/Emoticons/emoticons.plist") as? Array<NSDictionary>
        
//        let a: Array<Dictionary<String, AnyObject>>? = arr?.flatMap {
//            
//            let em = SIMChatBaseEmoticon()
//            
//            let dv = { (v: String?) -> String? in
//                if let str = v as? NSString where str.hasPrefix("[") && str.hasSuffix("]") {
//                    return str.substringWithRange(NSMakeRange(1, str.length - 2))
//                }
//                return v
//            }
//            
//            em.name = dv($0["chs"] as? String)
//            em.code = "/" + dv($0["chs"] as? String)!
//            em.image = $0["png"] as? String
//            em.image_gif = $0["gif"] as? String
//            
//            return em.toDictionary()
////            var u: UInt32 = 0
////            NSScanner(string: v).scanHexInt(&u)
////            
////            let x = String(Character(UnicodeScalar(u)))
////            
////            if let idx = ems?.indexOf({
////                return $0.name == x
////            }) {
////                return ems![idx].toDictionary()
////            }
//        }
//        (a as! NSArray).writeToFile("/Users/sagesse/Desktop/Info.plist", atomically: true)
        
        DispatchQueue.main.async {
            if let window = self.window {
                let label = SIMChatFPSLabel(frame: CGRect(x: window.bounds.width - 55 - 8, y: 20, width: 55, height: 20))
                label.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
                window.addSubview(label)
            }
        }
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

