//
//  UIView+MQRecursiveLevelLog.m
//  abc
//
//  Created by 马权 on 5/22/15.
//  Copyright (c) 2015 maquan. All rights reserved.
//

#import "UIView+MQRecursiveLevelLog.h"
#import "AppMacroObjc.h"

@implementation UIView (MQRecursiveLevelLog)

- (void)recursiveLevelLog:(MQRecursiveLevelLogType)logType maxLevel:(NSInteger)maxLevel {
    [self recursiveLevelLog:logType currentLevel:0 maxLevel:maxLevel];
}

- (void)recursiveLevelLog:(MQRecursiveLevelLogType)logType currentLevel:(NSInteger)currentLevel maxLevel:(NSInteger)maxLevel {
    NSString *levelLog = @"";
    for (NSInteger i = 0; i < currentLevel; i++) {
        levelLog = [levelLog stringByAppendingString:@" | "];
    }
    NSString *desLog = @"";
    if (logType & MQRecursiveLevelLogDescription) {
        desLog = [desLog stringByAppendingString:self.description];
    }
    else {
        if (logType & MQRecursiveLevelLogClassName) {
            desLog = [desLog stringByAppendingString:[NSString stringWithFormat:@"%@ ; ", NSStringFromClass(self.class)]];
        }
        if (logType & MQRecursiveLevelLogAddress) {
            desLog = [desLog stringByAppendingString:[NSString stringWithFormat:@"%p ; ", self]];
        }
        if (logType & MQRecursiveLevelLogFrame) {
            desLog = [desLog stringByAppendingString:[NSString stringWithFormat:@"%@ ; ", NSStringFromCGRect(self.frame)]];
        }
    }
    NSLog(@"%@ %@", levelLog, desLog);
    
    NSInteger nextLevel = currentLevel + 1;
    if (nextLevel > maxLevel) {
        return;
    }
    for (UIView *view in self.subviews) {
        [view recursiveLevelLog:logType currentLevel:nextLevel maxLevel:maxLevel];
    }
}

@end
