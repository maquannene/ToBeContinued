//
//  ImageDownloadGroupManage.swift
//  vb
//
//  Created by 马权 on 5/16/16.
//  Copyright © 2016 maquan. All rights reserved.
//

import Foundation
import Kingfisher

public let ImageDownloadDefaultGroupIdentifier = "mkf.download.group.default";

public class ImageDownloadGroup {
    public var maxConcurrentDownloads: Int = 20
    
    var _identifier: String
    var _downloadTaskKeys: [String]
    var _downloadTasksDic: [String : [RetrieveImageTask]]
    
    public init(identifier: String) {
        _identifier = identifier
        _downloadTaskKeys = [String]()
        _downloadTasksDic = [String : [RetrieveImageTask]]()
    }
    
    public convenience init () {
        self.init(identifier: ImageDownloadDefaultGroupIdentifier)
    }
    
    func addTask(task: RetrieveImageTask, forKey key: String) {
        if let index = _downloadTaskKeys.indexOf(key) {
            _downloadTaskKeys.removeAtIndex(index)
            _downloadTaskKeys.insert(key, atIndex: 0)
            if var tasks = _downloadTasksDic[key] as [RetrieveImageTask]? {
                tasks.append(task)
                _downloadTasksDic[key] = tasks
            }
            else {
                _downloadTasksDic[key] = [task]
            }
            if _downloadTaskKeys.count > maxConcurrentDownloads {
                if let lastKey = _downloadTaskKeys.last, tasks = _downloadTasksDic[lastKey] as [RetrieveImageTask]? {
                    tasks.forEach {
                        $0.cancel()
                    }
                    _downloadTasksDic.removeValueForKey(lastKey)
                    _downloadTaskKeys.removeLast()
                }
            }
        }
        else {
            _downloadTaskKeys.insert(key, atIndex: 0)
            _downloadTasksDic[key] = [task]
        }
    }
    
    func removeTask(key: String) {
        if var tasks = _downloadTasksDic[key] as [RetrieveImageTask]? {
            if !tasks.isEmpty {
                tasks = tasks.filter {
                    return ($0.downloadTask?.URL?.absoluteString != nil) && $0.downloadTask?.URL?.absoluteString != key
                }
                _downloadTasksDic[key] = tasks
            }
            if tasks.isEmpty {
                _downloadTaskKeys = _downloadTaskKeys.filter { $0 != key }
                _downloadTasksDic.removeValueForKey(key)
            }
        }
    }
}

public class ImageDownloadGroupManage {
    
    var _downloadGroupsArray: [ImageDownloadGroup]
    
    public static let shareInstance = ImageDownloadGroupManage()
    
    init() {
        _downloadGroupsArray = [ImageDownloadGroup]()
    }

    public func addGroup(group: ImageDownloadGroup) {
        if !_downloadGroupsArray.isEmpty, let _ = _downloadGroupsArray.filter( { $0._identifier == group._identifier } )[0] as ImageDownloadGroup? {
            return
        }
        _downloadGroupsArray.append(group)
    }
    
    public func removeGroup(identifier: String) {
        if let index = _downloadGroupsArray.indexOf({ $0._identifier == identifier }) {
            _downloadGroupsArray.removeAtIndex(index)
        }
    }
    
    public func addImageDownloadTask(task: RetrieveImageTask, toGroup identifier: String, forKey key: String) {
        if !_downloadGroupsArray.isEmpty, let downloadGroup = _downloadGroupsArray.filter( { $0._identifier == identifier } ).first as ImageDownloadGroup? {
            downloadGroup.addTask(task, forKey: key)
            return
        }
        let downloadGroup = ImageDownloadGroup(identifier: identifier)
        _downloadGroupsArray.append(downloadGroup)
        downloadGroup.addTask(task, forKey: key)
    }
    
    public func removeImageDownloadTask(key: String, fromGroup identifier: String) {
        if !_downloadGroupsArray.isEmpty, let downloadGroup = _downloadGroupsArray.filter( { $0._identifier == identifier } )[0] as ImageDownloadGroup? {
            downloadGroup.removeTask(key)
        }
    }
}