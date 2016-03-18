//
//  MQImageDownloadManage.m
//  vb
//
//  Created by 马权 on 3/17/16.
//  Copyright © 2016 maquan. All rights reserved.
//

#import "MQImageDownloadManage.h"
#import "SDWebImageManager.h"

@interface MQImageDownloadManage ()

{
    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSMutableArray<id<SDWebImageOperation>> *> *> *_downloadGroupsDic;
    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *_downloadGroupsKeysDic;
}

@end

@implementation MQImageDownloadManage

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MQImageDownloadManage alloc] init];
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

- (void)setImageDownLoadOperation:(id<SDWebImageOperation>)operation toGroup:(NSString *)groupIdentifier forKey:(NSString *)key
{
    NSMutableArray<NSString *> *downloadGroupKeys = _downloadGroupsKeysDic[groupIdentifier];
    NSMutableDictionary<NSString *, NSMutableArray<id<SDWebImageOperation>> *> *downloadGroup = _downloadGroupsDic[groupIdentifier];
    
    if (downloadGroupKeys) {
        if ([downloadGroupKeys containsObject:key]) {
            [downloadGroupKeys removeObject:key];
            [downloadGroupKeys insertObject:key atIndex:0];
            NSMutableArray<id<SDWebImageOperation>> *operations = downloadGroup[key];
            [operations addObject:operation];
        }
        else {
            NSMutableArray<id<SDWebImageOperation>> *operations = [@[operation] mutableCopy];
            downloadGroup[key] = operations;
            [downloadGroupKeys insertObject:key atIndex:0];
        }
        if ([downloadGroupKeys count] > 4) {
            NSString *lastKey = [downloadGroupKeys lastObject];
            NSMutableArray<id<SDWebImageOperation>> *lastOperations = downloadGroup[lastKey];
            [lastOperations enumerateObjectsUsingBlock:^(id<SDWebImageOperation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj cancel];
            }];
            [downloadGroup removeObjectForKey:lastKey];
            [downloadGroupKeys removeLastObject];
        }
    }
    else {
        NSMutableArray<id<SDWebImageOperation>> *operations = [@[operation] mutableCopy];
        
        downloadGroupKeys = [@[] mutableCopy];
        downloadGroup = [@{} mutableCopy];
        
        downloadGroupKeys[0] = key;
        downloadGroup[key] = operations;
        
        _downloadGroupsKeysDic[groupIdentifier] = downloadGroupKeys;
        _downloadGroupsDic[groupIdentifier] = downloadGroup;
    }
    NSLog(@"213");
}

- (void)removeImageDownLoadOperation:(id<SDWebImageOperation>)operation fromGroup:(NSString *)groupIdentifier forKey:(NSString *)key
{
    NSMutableDictionary<NSString *, NSMutableArray<id<SDWebImageOperation>> *> *downloadGroup = _downloadGroupsDic[groupIdentifier];
    NSMutableArray<id<SDWebImageOperation>> *operations = downloadGroup[key];
    [operations removeObject:operation];
}

@end
