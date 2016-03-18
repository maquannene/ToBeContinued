//
//  MQImageDownloadManage.h
//  vb
//
//  Created by 马权 on 3/17/16.
//  Copyright © 2016 maquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SDWebImageOperation;

@interface MQImageDownloadManage : NSObject

+ (instancetype)shareInstance;

- (void)setImageDownLoadOperation:(id<SDWebImageOperation>)operation toGroup:(NSString *)groupIdentifier forKey:(NSString *)key;

- (void)removeImageDownLoadOperation:(id<SDWebImageOperation>)operation fromGroup:(NSString *)groupIdentifier forKey:(NSString *)key;
//
//- (void)cancelImageDownLoadOperationGroup:(NSString *)groupIdentifier;

@end
