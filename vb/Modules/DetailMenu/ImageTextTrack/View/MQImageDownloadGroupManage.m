//
//  MQImageDownloadGroupManage.m
//  vb
//
//  Created by 马权 on 3/17/16.
//  Copyright © 2016 maquan. All rights reserved.
//

#import "MQImageDownloadGroupManage.h"
#import "SDWebImageManager.h"

NSString *const MQImageDownloadDefaultGroupIdentifier = @"mq.download.group.default";

@interface MQImageDownloadGroup ()

{
@public
    NSMutableDictionary<NSString *, NSMutableArray<id<SDWebImageOperation>> *> *_downloadOperationsDic;
    NSMutableArray<NSString *> *_downloadOperationKeys;
    NSString *_identifier;
}

@end

@implementation MQImageDownloadGroup

- (instancetype)init
{
    self = [self initWithGroupIdentifier:MQImageDownloadDefaultGroupIdentifier];
    if (self) {

    }
    return self;
}

- (instancetype)initWithGroupIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _downloadOperationsDic = [@{} mutableCopy];
        _downloadOperationKeys = [@[] mutableCopy];
        _maxConcurrentDownloads = 10;
        _identifier = [identifier copy];
    }
    return self;
}

@end

@implementation MQImageDownloadGroupManage

{
    NSMutableDictionary<NSString *, MQImageDownloadGroup *> *_downloadGroupsDic;
}

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MQImageDownloadGroupManage alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloadGroupsDic = [@{} mutableCopy];
    }
    return self;
}

- (void)addGroup:(MQImageDownloadGroup *)group
{
    MQImageDownloadGroup *downloadGroup = _downloadGroupsDic[group->_identifier];
    if (downloadGroup) {
        return;
    }
    _downloadGroupsDic[group->_identifier] = group;
}

- (void)removeGroupWithIdentifier:(NSString *)identifier
{
    [_downloadGroupsDic removeObjectForKey:identifier];
}

- (void)setImageDownLoadOperation:(id<SDWebImageOperation>)operation toGroup:(NSString *)identifier forKey:(NSString *)key
{
    MQImageDownloadGroup *downloadGroup = _downloadGroupsDic[identifier];
    NSMutableArray<NSString *> *downloadOperationKeys = downloadGroup->_downloadOperationKeys;
    
    if (downloadGroup && downloadOperationKeys) {
        if ([downloadOperationKeys containsObject:key]) {
            [downloadOperationKeys removeObject:key];
            [downloadOperationKeys insertObject:key atIndex:0];
            NSMutableArray<id<SDWebImageOperation>> *operations = downloadGroup->_downloadOperationsDic[key];
            [operations addObject:operation];
        }
        else {
            NSMutableArray<id<SDWebImageOperation>> *operations = [@[operation] mutableCopy];
            downloadGroup->_downloadOperationsDic[key] = operations;
            [downloadOperationKeys insertObject:key atIndex:0];
        }
        if ([downloadOperationKeys count] > downloadGroup.maxConcurrentDownloads) {
            NSString *lastKey = [downloadOperationKeys lastObject];
            NSMutableArray<id<SDWebImageOperation>> *lastOperations = downloadGroup->_downloadOperationsDic[lastKey];
            [lastOperations enumerateObjectsUsingBlock:^(id<SDWebImageOperation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj cancel];
            }];
            [downloadGroup->_downloadOperationsDic removeObjectForKey:lastKey];
            [downloadOperationKeys removeLastObject];
        }
    }
    else {
        NSMutableArray<id<SDWebImageOperation>> *operations = [@[operation] mutableCopy];
        
        downloadGroup = [[MQImageDownloadGroup alloc] initWithGroupIdentifier:identifier];
        _downloadGroupsDic[identifier] = downloadGroup;
        
        downloadGroup->_downloadOperationKeys[0] = identifier;
        downloadGroup->_downloadOperationsDic[identifier] = operations;
    }
}

- (void)removeImageDownLoadOperation:(id<SDWebImageOperation>)operation fromGroup:(NSString *)identifier forKey:(NSString *)key
{
    MQImageDownloadGroup *downloadGroup = _downloadGroupsDic[identifier];
    NSMutableArray<id<SDWebImageOperation>> *operations = downloadGroup->_downloadOperationsDic[key];
    [operations removeObject:operation];
    if (operations.count == 0) {
        [downloadGroup->_downloadOperationKeys removeObject:key];
        [downloadGroup->_downloadOperationsDic removeObjectForKey:key];
    }
}

@end
