//
//  UIViewController+md.m
//  MDPageView
//
//  Created by hq on 2022/3/25.
//

#import "UIViewController+md.h"
#import <objc/runtime.h>

static const char *childScrollViewKey = "childScrollViewKey";

@implementation UIViewController (md)

- (void)setChildScrollView:(UIScrollView *)childScrollView {
    objc_setAssociatedObject(self, childScrollViewKey, childScrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)childScrollView {
    return objc_getAssociatedObject(self, childScrollViewKey);
}


@end
