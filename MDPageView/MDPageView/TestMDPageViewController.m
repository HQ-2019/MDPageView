//
//  TestMDPageViewController.m
//  MDPageView
//
//  Created by hq on 2022/2/24.
//

#import "TestMDPageViewController.h"
#import "MDSubViewController.h"
#import "MDPageViewController.h"
#import "MDTabView.h"

@interface TestMDPageViewController ()

@property (nonatomic, strong) MDTabView *tabView;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) MDPageViewController *pageController;

@end

@implementation TestMDPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"MDPageViewController";
    
    __weak typeof(self) weakSelf = self;
    NSInteger showIndex = 1;
    
    
    MDPageViewController *controller = [MDPageViewController new];
    controller.view.frame = CGRectMake(0, self.tabView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.tabView.bounds.size.height);
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    self.pageController = controller;
    
    
    UIScrollView *headerView = [UIScrollView new];
    headerView.backgroundColor = UIColor.orangeColor;
    headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 100);
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    headerView.pagingEnabled = YES;
    headerView.contentSize = CGSizeMake(5 * headerView.bounds.size.width, headerView.bounds.size.height);
    [controller updateHeaderView:headerView];
    
    [controller updateViewControllers:self.viewControllers];
    [controller showPageAtIndex:showIndex animated:NO];
    
    controller.viewScrollCallBack = ^(CGPoint contentOffset, CGSize contentSize, BOOL isDragging) {
        //        NSLog(@"Offset: %@    isDragging: %@", @(contentOffset.x), @(isDragging));
    };
    controller.viewWillChangedCallBack = ^(NSInteger appearIndex, NSInteger disappearIndex) {
        //        NSLog(@"----------------------------------   页面将要切换  %@ -> %@", @(fromIndex), @(toIndex));
        [weakSelf.tabView showAtIndex:appearIndex];
    };
    controller.viewDidChangedCallBack = ^(NSInteger appearIndex, NSInteger disappearIndex) {
        NSLog(@"==================================   页面切换完成  %@ -> %@ \n", @(disappearIndex), @(appearIndex));
        [weakSelf.tabView showAtIndex:appearIndex];
    };
    
    
    // 模拟重置子视图控制器列表
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"重置 ################################");
//        NSArray *colors = @[ UIColor.grayColor, UIColor.orangeColor, UIColor.purpleColor, UIColor.redColor, UIColor.blueColor,UIColor.yellowColor, UIColor.purpleColor];
//        NSMutableArray *vcList = @[].mutableCopy;
//        [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            MDSubViewController *controller = [MDSubViewController new];
//            controller.content = [NSString stringWithFormat:@"页面： %@", @(idx)];
//            controller.color = obj;
//            [vcList addObject:controller];
//        }];
//        self.viewControllers = vcList;
//        [controller updateViewControllers:vcList];
//        [controller showPageAtIndex:2 animated:NO];
//        
//        self.tabView.count = self.viewControllers.count;
//    });
    
    [self.tabView showAtIndex:showIndex];
    self.tabView.clickIndexBlock = ^(NSInteger index) {
        [controller showPageAtIndex:index animated:YES];
    };
}

- (MDTabView *)tabView {
    if (!_tabView) {
        _tabView = [[MDTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        _tabView.count = self.viewControllers.count;
        [self.view addSubview:_tabView];
    }
    return _tabView;
}

- (NSArray *)viewControllers{
    if (!_viewControllers) {
        NSArray *colors = @[UIColor.yellowColor, UIColor.purpleColor, UIColor.redColor, UIColor.blueColor, UIColor.grayColor, UIColor.orangeColor, UIColor.purpleColor, UIColor.redColor, UIColor.blueColor,UIColor.yellowColor, UIColor.purpleColor, UIColor.redColor, UIColor.blueColor, UIColor.grayColor, UIColor.orangeColor, UIColor.purpleColor, UIColor.redColor, UIColor.blueColor];
        NSMutableArray *vcList = @[].mutableCopy;
        __weak typeof(self) weakSelf = self;
        [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MDSubViewController *controller = [MDSubViewController new];
            controller.content = [NSString stringWithFormat:@"页面： %@", @(idx)];
            controller.color = obj;
            controller.showListView = idx % 2 != 0;
            [vcList addObject:controller];
            controller.childDidScroll = ^(UIScrollView * _Nonnull scrollView) {
                [weakSelf.pageController childScrolling:scrollView index:idx];
            };
        }];
        
        _viewControllers = [NSArray arrayWithArray:vcList];
    }
    return _viewControllers;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), NSStringFromClass([self class]));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), NSStringFromClass([self class]));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), NSStringFromClass([self class]));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), NSStringFromClass([self class]));
}

@end
