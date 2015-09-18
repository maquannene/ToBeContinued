//
//  SWCellScrollView.m
//  SWTableViewCell
//
//  Created by Matt Bowman on 11/27/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "SWCellScrollView.h"

@implementation SWCellScrollView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
//    if (gestureRecognizer == self.panGestureRecognizer) {
//        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:gestureRecognizer.view];
//        return fabs(translation.y) <= fabs(translation.x);
//    } else {
//        return YES;
//    }
    
    //  change: maquan
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    // Find out if the user is actively scrolling the tableView of which this is a member.
//    // If they are, return NO, and don't let the gesture recognizers work simultaneously.
//    //
//    // This works very well in maintaining user expectations while still allowing for the user to
//    // scroll the cell sideways when that is their true intent.
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        
//        // Find the current scrolling velocity in that view, in the Y direction.
//        CGFloat yVelocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view].y;
//        
//        // Return YES iff the user is not actively scrolling up.
//        return fabs(yVelocity) <= 0.25;
//        
//    }
//    return YES;
    
    //  change: maquan  收起right button后快速tap tap要相应需共存
    if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    //  其他情况不共存 所以上面那个代理就不需要再判断pan是否成立。 如果是上下就触发 tableview的pan  左右 触发cell的scrollview上的pan
    return NO;
}

@end

