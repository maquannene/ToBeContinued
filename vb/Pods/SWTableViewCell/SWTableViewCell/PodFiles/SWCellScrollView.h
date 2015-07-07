//
//  SWCellScrollView.h
//  SWTableViewCell
//
//  Created by Matt Bowman on 11/27/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWCellScrollView : UIScrollView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UITableView *containingTableView;
@property (nonatomic, weak) UITableViewCell *containingCell;

@end
