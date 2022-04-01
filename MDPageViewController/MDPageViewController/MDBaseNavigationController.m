//
//  MDBaseNavigationController.m
//  MDPageViewController
//
//  Created by hq on 2022/4/1.
//

#import "MDBaseNavigationController.h"

@interface MDBaseNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation MDBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏
    self.navigationBar.translucent = NO;
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        appearance.backgroundColor = UIColor.redColor;
        [appearance setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.whiteColor}];
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        self.navigationBar.barTintColor = UIColor.redColor;
        self.navigationBar.barTintColor = UIColor.purpleColor;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.whiteColor}];
    }
    
    // 设置全屏手势
    [self reSetScreenGesture];
}

/// 重置侧滑返回手势，支持全屏侧滑返回
/// 在需要实现全屏侧滑返回的控制器页面添加下面两行代码
/// self.navigationController.interactivePopGestureRecognizer.enabled = YES;
/// self.navigationController.interactivePopGestureRecognizer.delegate = self;
- (void)reSetScreenGesture {
    id target = self.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];

    self.interactivePopGestureRecognizer.enabled = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    if (self.childViewControllers.count == 1) {
        return NO;
    }

    // 如果页面正处于过渡阶段,不响应手势
    if ([[self valueForKey:@"_isTransitioning"] boolValue])
    {
        return NO;
    }

    return YES;
}


@end
