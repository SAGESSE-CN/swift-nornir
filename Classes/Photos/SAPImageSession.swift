//
//  SAPImageSession.swift
//  SAPhotos
//
//  Created by SAGESSE on 11/11/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

class SAPImageSession: NSObject {
    
    
    private func _requestImage(with request: SAPImageRequest,  progressHandler: @escaping (Double, Error?) -> Void, resultHandler: @escaping (UIImage?, SAPImageResponse, Error?) -> Void) {
        
        let option = PHImageRequestOptions()
        let manager = PHCachingImageManager.default()
        
        option.version = request.version
        option.resizeMode = request.resizeMode
        option.deliveryMode = request.deliveryMode
        
        option.isSynchronous = request.isSynchronous
        option.isNetworkAccessAllowed = request.isNetworkAccessAllowed
        
        option.normalizedCropRect = request.normalizedCropRect
        option.progressHandler = { (progress, error, stop, info) in
            _SAPImageSessionQueueTasksAdd(.main) {
                progressHandler(progress, error)
            }
        }
        
        let size = request.targetSize
        let mode = request.targetContentMode
        
        manager.requestImage(for: request.asset, targetSize: size, contentMode: mode, options: option) { image, info in
            let response = SAPImageResponse(request: request, image: image, info: info)
            request.requestId = response.requestId
            // 请求完成了?
            if !response.isDegraded || response.isCancelled || response.error != nil {
                response.requestId = PHInvalidImageRequestID
                request.requestId = PHInvalidImageRequestID
            }
            _SAPImageSessionQueueTasksAdd(.main) {
                resultHandler(image, response, response.error)
            }
        }
    }
    
    func imageTask(with request: SAPImageRequest) -> SAPImageSessionTask {
        let format = _SAPImageSessionMakeFormat(request)
        if let task = _tasks[request.asset.localIdentifier]?[format] {
            // hit cache
            return task
        }
        let task = SAPImageSessionTask(request: request)
        let tsize = request.targetSize
        let identifier = request.asset.localIdentifier
        
        task.session = self
        
        //print("+--> start task", identifier, tsize)
        _requestImage(with: request, progressHandler: { [weak task] progress, error in 
            //print("|    update progress", identifier, tsize, progress, error)
            guard let task = task else {
                return
            }
            task.updateProgress(progress)
        }, resultHandler: { [weak task]image, response, error in 
            guard let task = task else {
                return
            }
            // 请求结束?
            guard response.requestId != PHInvalidImageRequestID else {
                // 正常结束?
                if let image = image, let tasks = self._tasks[identifier] {
                    tasks.forEach { key, value in
                        value.updateTask(image, nil)
                    }
                }
                task.finishTask(image, response)
                //print("+--> finish task", identifier, tsize, image, error)
                return
            } 
            //print("|--> update result", identifier, tsize, image, error)
            // 更新缩略图.
            var thumb: UIImage?
            // 检查内存中有没有图片, 如果有使用
            self._tasks[identifier]?.forEach { key, value in
                guard let newImage = value.data else {
                    return
                }
                // 检查是否可以使用(必须小于targetsize和大小thumb)
                let nsize = newImage.size
                guard (nsize.width >= tsize.width && nsize.height >= tsize.height)
                    || (tsize.width == -1 || tsize.height == -1) else {
                    return
                }
                let csize = thumb?.size ?? .zero
                guard nsize.width >= csize.width && nsize.height >= csize.height else {
                    return
                }
                thumb = newImage
            }
            task.updateTask(thumb ?? image, response)
            // 检查是否图片还在cloud上面
            guard thumb == nil && !request.isSynchronous && request.isNetworkAccessAllowed && response.isInCloud else {
                return
            }
            // 检查是否需要加载, 如果图片太小也是不需要加载的
            let misize = CGSize(width: 240, height: 240)
            let miscale = CGFloat(2)
            guard (tsize.width > misize.width * miscale && tsize.height > misize.height * miscale) 
                || (tsize.width == -1 || tsize.height == -1) else {
                return
            }
            // 可能需要加载缩略图, 延迟n秒, 如在这个时间内还没获取到发送请求
            let n: TimeInterval = 0.5
            self._requestQueue.asyncAfter(deadline: .now() + .milliseconds(Int(n * 1000))) { [weak task] in
                guard let task = task else {
                    // 己经取消
                    return
                }
                guard request.requestId != PHInvalidImageRequestID else {
                    return
                }
                let csize = task.data?.size ?? .zero
                guard csize.width < misize.width * miscale && csize.height < misize.height * miscale else {
                    // 他己经有一个很大的图片了
                    return
                }
                //print("+--> request thumb image", identifier, tsize, image, error)
                // 请求
                let req2 = SAPImageRequest(asset: request.asset, size: misize, contentMode: .aspectFit)
                req2.deliveryMode = .opportunistic
                req2.resizeMode = .fast
                req2.isNetworkAccessAllowed = true
                task.thumbTask = self.imageTask(with: req2)
            }
        })
        return task
    }
    
    func cancelRequest(with request: SAPImageRequest) {
        guard request.requestId != PHInvalidImageRequestID else {
            return
        }
        //print("+--> cancel request", request.asset.localIdentifier, request.targetSize)
        let manager = PHCachingImageManager.default()
        manager.cancelImageRequest(request.requestId)
    }
    
    private lazy var _tasks: Dictionary<String, WKDictionary<Int, SAPImageSessionTask>> = [:]
    private lazy var _requestQueue: DispatchQueue = DispatchQueue(label: "SAPImageRequestQueue")
}

private func _SAPImageSessionMakeFormat(_ request: SAPImageRequest) -> Int {
    let asset = request.asset
    let targetSize = request.targetSize
    let contentMode = request.targetContentMode
    guard targetSize.width != 0 && targetSize.height != 0 && asset.pixelWidth != 0 && asset.pixelHeight != 0 else {
        return 0
    }
    guard targetSize.width != -1 && targetSize.height != -1 else {
        return -1
    }
    
    let w = CGFloat(asset.pixelWidth) 
    let h = CGFloat(asset.pixelHeight)
    
    let tmf: (CGFloat, CGFloat) -> CGFloat = (contentMode == .aspectFit) ? max : min
    let scale: CGFloat = tmf(targetSize.width / w, targetSize.height / h)
    
    return Int(w * scale)
}

private var _SAPImageSessionQueueTasks: Array<() -> Void>?
private func _SAPImageSessionQueueTasksAdd(_ queue: DispatchQueue, task: @escaping () -> Void) {
    queue.async {
        task()
    }
//    // 合并任务, 减少线程唤醒次数
//    objc_sync_enter(SAPImageSession.self)
//    
//    var isstart = _SAPImageSessionQueueTasks != nil
//    if _SAPImageSessionQueueTasks == nil {
//        _SAPImageSessionQueueTasks = [task]
//    } else {
//        _SAPImageSessionQueueTasks?.append(task)
//    }
//    
//    objc_sync_exit(SAPImageSession.self)
//    
//    guard !isstart else {
//        return
//    }
//    // 开启线程
//    queue.async {
//        objc_sync_enter(SAPImageSession.self)
//        let tasks = _SAPImageSessionQueueTasks
//        _SAPImageSessionQueueTasks = nil
//        objc_sync_exit(SAPLibrary.self)
//        
//        tasks?.forEach {
//            $0()
//        }
//    }
}

