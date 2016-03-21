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

@property (nonatomic, strong) NSURL *mq_imageURL;
@property (nonatomic, copy) NSString *mq_downloadGroupIdentifier;
@property (nonatomic, strong) id<SDWebImageOperation> mq_operation;

@end

@implementation UIImageView (mq_WebCache)

//  MARK: objc_setAssociatedObject
- (void)setMq_imageURL:(NSURL *)mq_imageURL
{
    objc_setAssociatedObject(self, @selector(mq_imageURL), mq_imageURL, OBJC_ASSOCIATION_RETAIN);
}

- (NSURL *)mq_imageURL
{
    return objc_getAssociatedObject(self, @selector(mq_imageURL));
}

- (void)setMq_downloadGroupIdentifier:(NSString *)mq_downloadGroupIdentifier
{
    objc_setAssociatedObject(self, @selector(mq_downloadGroupIdentifier), mq_downloadGroupIdentifier, OBJC_ASSOCIATION_COPY);
}

- (NSString *)mq_downloadGroupIdentifier
{
    return objc_getAssociatedObject(self, @selector(mq_downloadGroupIdentifier));
}

- (void)setMq_operation:(id<SDWebImageOperation>)mq_operation
{
    objc_setAssociatedObject(self, @selector(mq_operation), mq_operation, OBJC_ASSOCIATION_RETAIN);
}

- (id<SDWebImageOperation>)mq_operation
{
    return objc_getAssociatedObject(self, @selector(mq_operation));
}

//  MARK: Public
- (void)mq_setImageWithURL:(NSURL *)url
{
    [self mq_setImageWithURL:url groupIdentifier:MQImageDownloadDefaultGroupIdentifier placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)mq_setImageWithURL:(NSURL *)url
           groupIdentifier:(NSString *)identifier
{
    [self mq_setImageWithURL:url groupIdentifier:identifier placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)mq_setImageWithURL:(NSURL *)url
           groupIdentifier:(NSString *)identifier
          placeholderImage:(UIImage *)placeholder
                   options:(SDWebImageOptions)options
{
    [self mq_setImageWithURL:url groupIdentifier:identifier placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)mq_setImageWithURL:(NSURL *)url
                 completed:(SDWebImageCompletionBlock)completedBlock
{
    [self mq_setImageWithURL:url groupIdentifier:MQImageDownloadDefaultGroupIdentifier placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)mq_setImageWithURL:(NSURL *)url
           groupIdentifier:(NSString *)identifier
                 completed:(SDWebImageCompletionBlock)completedBlock
{
    [self mq_setImageWithURL:url groupIdentifier:identifier placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)mq_setImageWithURL:(NSURL *)url
           groupIdentifier:(NSString *)identifier
          placeholderImage:(UIImage *)placeholder
                   options:(SDWebImageOptions)options
                 completed:(SDWebImageCompletionBlock)completedBlock
{
    [self mq_setImageWithURL:url groupIdentifier:identifier placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)mq_setImageWithURL:(NSURL *)url
           groupIdentifier:(NSString *)identifier
          placeholderImage:(UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(SDWebImageCompletionBlock)completedBlock
{
    self.mq_imageURL = url;
    
    NSString *captureURLString = url.absoluteString;
    
    __weak typeof(self) weakSelf = self;
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            if (!weakSelf) {
                return;
            }
            if ([weakSelf.mq_imageURL.absoluteString isEqualToString:captureURLString]) {
                weakSelf.image = placeholder;
            }
        });
    }
    
    if (url) {
        __weak typeof(self) weakSelf = self;
        __block id <SDWebImageOperation> operation = [[SDWebImageManager sharedManager] downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (operation && identifier) {
                    [[MQImageDownloadGroupManage shareInstance] removeImageDownLoadOperation:operation fromGroup:self.mq_downloadGroupIdentifier forKey:self.mq_imageURL.absoluteString];
                }
                if (!weakSelf) {
                    return;
                }
                if ([weakSelf.mq_imageURL.absoluteString isEqualToString:captureURLString]) {
                    weakSelf.mq_operation = nil;
                    weakSelf.mq_imageURL = nil;
                    weakSelf.mq_downloadGroupIdentifier = nil;
                    if (image) {
                        weakSelf.image = image;
                        [weakSelf setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, imageURL);
                }
            });
        }];
        
        if (operation && identifier) {
            [[MQImageDownloadGroupManage shareInstance] setImageDownLoadOperation:operation toGroup:identifier forKey:[url absoluteString]];
            self.mq_operation = operation;
            self.mq_downloadGroupIdentifier = identifier;
        }
    }
    else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)mq_cancelCurrentImageDownload
{
    id<SDWebImageOperation> operation = [self mq_operation];
    if (!operation) {
        return;
    }
    [operation cancel];
    [[MQImageDownloadGroupManage shareInstance] removeImageDownLoadOperation:operation fromGroup:self.mq_downloadGroupIdentifier forKey:self.mq_imageURL.absoluteString];
    self.mq_operation = nil;
    self.mq_imageURL = nil;
    self.mq_downloadGroupIdentifier = nil;
}

@end
