//
//  MDBaseScrollView.m
//  MDPageView
//
//  Created by hq on 2022/3/21.
//

#import "MDBaseScrollView.h"

@implementation MDBaseScrollView

// 返回YES，允许多个视图同时响起手势事件（允许手势同时透传到父视图）
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
