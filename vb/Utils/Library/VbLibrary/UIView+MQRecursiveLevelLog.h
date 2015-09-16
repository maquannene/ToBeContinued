//
//  UIView+MQRecursiveLevelLog.m
//  abc
//
//  Created by 马权 on 5/22/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, MQRecursiveLevelLogType) {
    MQRecursiveLevelLogClassName = 1 << 0,
    MQRecursiveLevelLogAddress = 1 << 1,
    MQRecursiveLevelLogFrame = 1 << 2,
    MQRecursiveLevelLogDescription = 1 << 3
};

@interface UIView (MQRecursiveLevelLog)

- (void)recursiveLevelLog:(MQRecursiveLevelLogType)logType maxLevel:(NSInteger)maxLevel;

@end
