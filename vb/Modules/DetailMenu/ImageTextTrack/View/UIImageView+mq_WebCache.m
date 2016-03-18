//
//  UIImageView+mq_WebCache.m
//  vb
//
//  Created by 马权 on 3/17/16.
//  Copyright © 2016 maquan. All rights reserved.
//

#import "UIImageView+mq_WebCache.h"
#import "SDWebImageManager.h"
#import "MQImageDownloadManage.h"

@implementation UIImageView (mq_WebCache)

- (void)mq_setImageWithURL:(NSURL *)url
           groupIdentifier:(NSString *)identifier
          placeholderImage:(UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(SDWebImageCompletionBlock)completedBlock
{
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
    if (url) {
        __weak typeof(self) weakSelf = self;
        __block id <SDWebImageOperation> operation = [[SDWebImageManager sharedManager] downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (operation) {
                    [[MQImageDownloadManage shareInstance] removeImageDownLoadOperation:operation fromGroup:identifier forKey:[url absoluteString]];
                }
                if (!weakSelf) {
                    return;
                }
                if (image) {
                    weakSelf.image = image;
                    [weakSelf setNeedsLayout];
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, imageURL);
                }
            });
        }];
        
        if (operation) {
            [[MQImageDownloadManage shareInstance] setImageDownLoadOperation:operation toGroup:identifier forKey:[url absoluteString]];
        }
    }
    
    dispatch_main_async_safe(^{
        NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
        if (completedBlock) {
            completedBlock(nil, error, SDImageCacheTypeNone, url);
        }
    });
}

@end
