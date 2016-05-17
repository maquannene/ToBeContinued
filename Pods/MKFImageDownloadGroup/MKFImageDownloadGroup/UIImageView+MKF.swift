//
//  UIImageView+MKF.swift
//  vb
//
//  Created by 马权 on 5/16/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import Foundation
import Kingfisher

public extension UIImageView {
    
    public func mkf_setImageWithURL(URL: NSURL,
                                    identifier: String? = nil,
                                    placeholderImage: UIImage? = nil,
                                    optionsInfo: KingfisherOptionsInfo? = nil,
                                    progressBlock: DownloadProgressBlock? = nil,
                                    completionHandler: CompletionHandler? = nil) -> RetrieveImageTask
    {
        return mkf_setImageWithResource(Resource(downloadURL: URL),
                                        identifier: identifier,
                                        placeholderImage: placeholderImage,
                                        optionsInfo: optionsInfo,
                                        progressBlock: progressBlock,
                                        completionHandler: completionHandler)
    }
    
    public func mkf_setImageWithResource(resource: Resource,
                                         identifier: String? = nil,
                                         placeholderImage: UIImage? = nil,
                                         optionsInfo: KingfisherOptionsInfo? = nil,
                                         progressBlock: DownloadProgressBlock? = nil,
                                         completionHandler: CompletionHandler? = nil) -> RetrieveImageTask
    {
        mkf_setImageURL(resource.downloadURL)
        
        let task = kf_setImageWithResource(resource, placeholderImage: placeholderImage, optionsInfo: optionsInfo, progressBlock: progressBlock) { [weak self] (image, error, cacheType, imageURL) in
            
            if let imageURLStr = imageURL?.absoluteString, identifier = identifier {
                ImageDownloadGroupManage.shareInstance.removeImageDownloadTask(imageURLStr, fromGroup: identifier)
            }
            
            guard let sSelf = self where imageURL == sSelf.mkf_imageURL else {
                completionHandler?(image: image, error: error, cacheType: cacheType, imageURL: imageURL)
                return
            }
            
            sSelf.mkf_setImageTask(nil)
            sSelf.mkf_setDownloadIdentifier(nil)
            
            completionHandler?(image: image, error: error, cacheType: cacheType, imageURL: imageURL)
        }
        
        if identifier != nil {
            var cache: ImageCache = ImageCache.defaultCache
            if let caches: [ImageCache] = optionsInfo?.flatMap ( {
                switch $0 {
                case let .TargetCache(cache):
                    return cache
                default:
                    return nil
                }
            }) where caches.count > 0 {
                cache = caches[0]
            }
            if cache.retrieveImageInDiskCacheForKey(resource.downloadURL.absoluteString) == nil {
                ImageDownloadGroupManage.shareInstance.addImageDownloadTask(task, toGroup: identifier!, forKey: resource.downloadURL.absoluteString)
                self.mkf_setDownloadIdentifier(identifier!)
            }
        }
        
        self.mkf_setImageTask(task)
        
        return task
    }
    
    public func mkf_cancelCurrentImageDownload() {
        if let task = self.mkf_imageTask as RetrieveImageTask? {
            task.cancel()
            self.mkf_setImageTask(nil)
            if let downloadIdentifier = self.mkf_downloadIdentifier, imageURL = self.mkf_imageURL {
                ImageDownloadGroupManage.shareInstance.removeImageDownloadTask(imageURL.absoluteString, fromGroup: downloadIdentifier)
                self.mkf_setImageURL(nil)
                self.mkf_setDownloadIdentifier(nil)
            }
        }
    }
}

// MARK: - Associated Object
private var mkfLastURLKey: Void?
private var mkfImageTaskKey: Void?
private var mfkDownloadIdentifierKey: Void?

public extension UIImageView {
    public var mkf_imageURL: NSURL? {
        return objc_getAssociatedObject(self, &mkfLastURLKey) as? NSURL
    }
    
    private func mkf_setImageURL(URL: NSURL?) {
        objc_setAssociatedObject(self, &mkfLastURLKey, URL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private var mkf_imageTask: RetrieveImageTask? {
        return objc_getAssociatedObject(self, &mkfImageTaskKey) as? RetrieveImageTask
    }
    
    private func mkf_setImageTask(task: RetrieveImageTask?) {
        objc_setAssociatedObject(self, &mkfImageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private var mkf_downloadIdentifier: String? {
        return objc_getAssociatedObject(self, &mfkDownloadIdentifierKey) as? String
    }
    
    private func mkf_setDownloadIdentifier(identifier: String?) {
        objc_setAssociatedObject(self, &mfkDownloadIdentifierKey, identifier, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}