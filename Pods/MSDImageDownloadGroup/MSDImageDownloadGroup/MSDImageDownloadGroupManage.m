//
//  MSDImageDownloadGroupManage.m
//  vb
//
//  Created by 马权 on 3/17/16.
//  Copyright © 2016 maquan. All rights reserved.
//

#import "MSDImageDownloadGroupManage.h"
#import "SDWebImageManager.h"

NSString *const MSDImageDownloadDefaultGroupIdentifier = @"msd.download.group.default";

@interface MSDImageDownloadGroup ()

{
@public
    NSMutableDictionary<NSString *, NSMutableArray<id<SDWebImageOperation>> *> *_downloadOperationsDic;
    NSMutableArray<NSString *> *_downloadOperationKeys;
    NSString *_identifier;
}

@end

@implementation MSDImageDownloadGroup

- (instancetype)init
{
    self = [self initWithGroupIdentifier:MSDImageDownloadDefaultGroupIdentifier];
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
        _maxConcurrentDownloads = 20;
        _identifier = [identifier copy];
    }
    return self;
}

- (void)addOperation:(id<SDWebImageOperation>)operation forKey:(NSString *)key
{
    if (_downloadOperationKeys) {
        if ([_downloadOperationKeys containsObject:key]) {
            [_downloadOperationKeys removeObject:key];
            [_downloadOperationKeys insertObject:key atIndex:0];
            NSMutableArray<id<SDWebImageOperation>> *operations = _downloadOperationsDic[key];
            [operations addObject:operation];
        }
        else {
            NSMutableArray<id<SDWebImageOperation>> *operations = [@[operation] mutableCopy];
            _downloadOperationsDic[key] = operations;
            [_downloadOperationKeys insertObject:key atIndex:0];
        }
        if ([_downloadOperationKeys count] > _maxConcurrentDownloads) {
            NSString *lastKey = [_downloadOperationKeys lastObject];
            NSMutableArray<id<SDWebImageOperation>> *lastOperations = _downloadOperationsDic[lastKey];
            [lastOperations makeObjectsPerformSelector:@selector(cancel)];
            [_downloadOperationsDic removeObjectForKey:lastKey];
            [_downloadOperationKeys removeLastObject];
        }
    }
    else {
        _downloadOperationKeys[0] = key;
        _downloadOperationsDic[key] = [@[operation] mutableCopy];
    }
}

- (void)removeOperation:(NSString *)key
{
    [_downloadOperationKeys removeObject:key];
    [_downloadOperationsDic removeObjectForKey:key];
}

@end

@implementation MSDImageDownloadGroupManage

{
    NSMutableDictionary<NSString *, MSDImageDownloadGroup *> *_downloadGroupsDic;
}

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MSDImageDownloadGroupManage alloc] init];
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


//  MARK: Public
- (void)addGroup:(MSDImageDownloadGroup *)group
{
    MSDImageDownloadGroup *downloadGroup = _downloadGroupsDic[group->_identifier];
    if (downloadGroup) {
        return;
    }
    _downloadGroupsDic[group->_identifier] = group;
}

- (void)removeGroupWithIdentifier:(NSString *)identifier
{
    [_downloadGroupsDic removeObjectForKey:identifier];
}

- (void)addImageDownLoadOperation:(id<SDWebImageOperation>)operation toGroup:(NSString *)identifier forKey:(NSString *)key
{
    MSDImageDownloadGroup *downloadGroup = _downloadGroupsDic[identifier];
    if (!downloadGroup) {
        downloadGroup = [[MSDImageDownloadGroup alloc] initWithGroupIdentifier:identifier];
        _downloadGroupsDic[identifier] = downloadGroup;
    }
    [downloadGroup addOperation:operation forKey:key];
}

- (void)removeImageDownLoadOperation:(NSString *)key fromGroup:(NSString *)identifier
{
    if (_debug) {
        NSLog(@"groups count = %lu\n", (unsigned long)_downloadGroupsDic.count);
        [_downloadGroupsDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MSDImageDownloadGroup * _Nonnull obj, BOOL * _Nonnull stop) {
            NSLog(@"group id = %@, key count = %lu\n", obj->_identifier, (unsigned long)obj->_downloadOperationsDic.count);
            [obj->_downloadOperationsDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray<id<SDWebImageOperation>> * _Nonnull obj, BOOL * _Nonnull stop) {
                NSLog(@"operation key = %@, operation count = %lu\n", key,  obj.count);
                [obj enumerateObjectsUsingBlock:^(id<SDWebImageOperation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSLog(@"operation = %@", obj);
                }];
            }];
        }];
    }
    MSDImageDownloadGroup *downloadGroup = _downloadGroupsDic[identifier];
    [downloadGroup removeOperation:key];
}

static BOOL _debug = NO;

- (void)debug:(BOOL)debug
{
    _debug = debug;
}

@end
