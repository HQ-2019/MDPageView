//
//  UIScrollView+md.m
//  MDPageView
//
//  Created by hq on 2022/3/24.
//

#import "UIScrollView+md.h"
#import <objc/runtime.h>

static const char *canSrcollKey = "canSrcollKey";

@implementation UIScrollView (md)

- (void)setCanScroll:(BOOL)canScroll {
    objc_setAssociatedObject(self, canSrcollKey, @(canScroll), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)canScroll {
    return [objc_getAssociatedObject(self, canSrcollKey) boolValue];
}

@end
