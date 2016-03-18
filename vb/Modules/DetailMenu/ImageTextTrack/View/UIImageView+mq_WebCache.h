//
//  UIImageView+mq_WebCache.h
//  vb
//
//  Created by 马权 on 3/17/16.
//  Copyright © 2016 maquan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import SDWebImage;

@interface UIImageView (mq_WebCache)

- (void)mq_setImageWithURL:(NSURL *)url
           groupIdentifier:(NSString *)identifier
          placeholderImage:(UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(SDWebImageCompletionBlock)completedBlock;

@end
