//
//  MQImageDownloadGroupManage.m
//  vb
//
//  Created by 马权 on 3/17/16.
//  Copyright © 2016 maquan. All rights reserved.
//

#import "MQImageDownloadGroupManage.h"
#import "SDWebImageManager.h"

@interface MQImageDownloadGroup ()

{
@public
    NSMutableDictionary<NSString *, NSMutableArray<id<SDWebImageOperation>> *> *_downloadOperationsDic;
    NSString *_identifier;
}

@end

@implementation MQImageDownloadGroup

- (instancetype)init
{
    self = [self initWithGroupIdentifier:@"default"];
    if (self) {

    }
    return self;
}

- (instancetype)initWithGroupIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _downloadOperationsDic = [@{} mutableCopy];
        _maxConcurrentDownloads = 10;
        _identifier = [identifier copy];
    }
    return self;
}

@end

@implementation MQImageDownloadGroupManage

{
    NSMutableDictionary<NSString *, MQImageDownloadGroup *> *_downloadGroupsDic;
    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *_downloadGroupsKeysDic;
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
        _downloadGroupsKeysDic = [@{} mutableCopy];
    }
    return self;
}

- (void)addGroup:(MQImageDownloadGroup *)group
{
    MQImageDownloadGroup *downloadGroup = _downloadGroupsDic[group->_identifier];
    if (downloadGroup) {
        return;
    }
    NSMutableArray<NSString *> *downloadGroupKeys = [@[] mutableCopy];
    _downloadGroupsKeysDic[group->_identifier] = downloadGroupKeys;
    _downloadGroupsDic[group->_identifier] = group;
}

- (void)removeGroupWithIdentifier:(NSString *)identifier
{
    [_downloadGroupsKeysDic removeObjectForKey:identifier];
    [_downloadGroupsDic removeObjectForKey:identifier];
}

- (void)setImageDownLoadOperation:(id<SDWebImageOperation>)operation toGroup:(NSString *)identifier forKey:(NSString *)key
{
    NSMutableArray<NSString *> *downloadGroupKeys = _downloadGroupsKeysDic[identifier];
    MQImageDownloadGroup *downloadGroup = _downloadGroupsDic[identifier];
    
    if (downloadGroupKeys && downloadGroup) {
        if ([downloadGroupKeys containsObject:key]) {
            [downloadGroupKeys removeObject:key];
            [downloadGroupKeys insertObject:key atIndex:0];
            NSMutableArray<id<SDWebImageOperation>> *operations = downloadGroup->_downloadOperationsDic[key];
            [operations addObject:operation];
        }
        else {
            NSMutableArray<id<SDWebImageOperation>> *operations = [@[operation] mutableCopy];
            downloadGroup->_downloadOperationsDic[key] = operations;
            [downloadGroupKeys insertObject:key atIndex:0];
        }
        if ([downloadGroupKeys count] > downloadGroup.maxConcurrentDownloads) {
            NSString *lastKey = [downloadGroupKeys lastObject];
            NSMutableArray<id<SDWebImageOperation>> *lastOperations = downloadGroup->_downloadOperationsDic[lastKey];
            [lastOperations enumerateObjectsUsingBlock:^(id<SDWebImageOperation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj cancel];
            }];
            [downloadGroup->_downloadOperationsDic removeObjectForKey:lastKey];
            [downloadGroupKeys removeLastObject];
        }
    }
    else {
        NSMutableArray<id<SDWebImageOperation>> *operations = [@[operation] mutableCopy];
        
        downloadGroupKeys = [@[] mutableCopy];
        downloadGroup = [[MQImageDownloadGroup alloc] initWithGroupIdentifier:identifier];
        
        downloadGroupKeys[0] = key;
        downloadGroup->_downloadOperationsDic[key] = operations;
        
        _downloadGroupsKeysDic[identifier] = downloadGroupKeys;
        _downloadGroupsDic[identifier] = downloadGroup;
    }
}

- (void)removeImageDownLoadOperation:(id<SDWebImageOperation>)operation fromGroup:(NSString *)identifier forKey:(NSString *)key
{
    MQImageDownloadGroup *downloadGroup = _downloadGroupsDic[identifier];
    NSMutableArray<id<SDWebImageOperation>> *operations = downloadGroup->_downloadOperationsDic[key];
    [operations removeObject:operation];
}

@end
