//
//  UIImageView+mq_WebCache.m
//  vb
//
//  Created by 马权 on 3/17/16.
//  Copyright © 2016 maquan. All rights reserved.
//

#import "UIImageView+mq_WebCache.h"
#import "SDWebImageManager.h"
#import "MQImageDownloadGroupManage.h"
#import "objc/runtime.h"

@interface UIImageView ()

@property (nonatomic, copy) NSString *mq_URLString;

@end

@implementation UIImageView (mq_WebCache)

- (void)mq_setImageWithURL:(NSURL *)url
           groupIdentifier:(NSString *)identifier
          placeholderImage:(UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(SDWebImageCompletionBlock)completedBlock
{
    self.mq_URLString = [url absoluteString];
    
    NSString *captureURLString = [url absoluteString];
    
    __weak typeof(self) weakSelf = self;
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            if (!weakSelf) {
                return;
            }
            if ([captureURLString isEqualToString:weakSelf.mq_URLString]) {
                weakSelf.image = placeholder;
            }
        });
    }
    
    if (url) {
        __weak typeof(self) weakSelf = self;
        __block id <SDWebImageOperation> operation = [[SDWebImageManager sharedManager] downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (operation) {
                    [[MQImageDownloadGroupManage shareInstance] removeImageDownLoadOperation:operation fromGroup:identifier forKey:[url absoluteString]];
                }
                if (!weakSelf) {
                    return;
                }
                if (image && [weakSelf.mq_URLString isEqualToString:captureURLString]) {
                    weakSelf.image = image;
                    [weakSelf setNeedsLayout];
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, imageURL);
                }
            });
        }];
        
        if (operation) {
            [[MQImageDownloadGroupManage shareInstance] setImageDownLoadOperation:operation toGroup:identifier forKey:[url absoluteString]];
        }
    }
    
    dispatch_main_async_safe(^{
        NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
        if (completedBlock) {
            completedBlock(nil, error, SDImageCacheTypeNone, url);
        }
    });
}

- (void)setMq_URLString:(NSString *)mq_URLString
{
    objc_setAssociatedObject(self, @selector(mq_URLString), mq_URLString, OBJC_ASSOCIATION_COPY);
}

- (NSString *)mq_URLString
{
    return objc_getAssociatedObject(self, @selector(mq_URLString));
}

@end
