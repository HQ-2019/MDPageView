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

@property (nonatomic, strong) UIScrollView *headerView;
@property (nonatomic, strong) MDTabView *tabView;
@property (nonatomic, strong) MDPageViewController *pageController;
@property (nonatomic, strong) NSArray *viewControllers;

@end

@implementation TestMDPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"MDPageViewController";
    self.view.backgroundColor = UIColor.whiteColor;
    
    __weak typeof(self) weakSelf = self;
    NSInteger showIndex = 1;
    
    MDPageViewController *controller = [MDPageViewController new];
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    self.pageController = controller;
    
    [controller updateHeaderView:self.headerView];
    [controller updateSubHeaderView:self.tabView];
    [controller updateViewControllers:self.viewControllers];
    
    [controller showPageAtIndex:showIndex animated:NO];
    
    // 底部容器上下滚动
    controller.baseScrollViewDidScrolling = ^(MDBaseScrollView * _Nonnull scrollView) {
        
    };
    
    // 分页容器左右滚动
    controller.pageScrollViewDidScrolling = ^(CGPoint contentOffset, CGSize contentSize, BOOL isDragging) {
        //        NSLog(@"Offset: %@    isDragging: %@", @(contentOffset.x), @(isDragging));
    };
    
    // 子页面视图将要切换
    controller.childViewWillChanged = ^(NSInteger appearIndex, NSInteger disappearIndex) {
        //        NSLog(@"----------------------------------   页面将要切换  %@ -> %@", @(fromIndex), @(toIndex));
        [weakSelf.tabView showAtIndex:appearIndex];
    };
    
    // 子页面视图完成切换
    controller.childViewDidChanged = ^(NSInteger appearIndex, NSInteger disappearIndex) {
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
        [weakSelf.pageController showPageAtIndex:index animated:YES];
    };
}

- (UIScrollView *)headerView {
    if (!_headerView) {
        UIScrollView *headerView = [UIScrollView new];
        headerView.backgroundColor = UIColor.orangeColor;
        headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 100);
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        headerView.pagingEnabled = YES;
        headerView.contentSize = CGSizeMake(5 * headerView.bounds.size.width, headerView.bounds.size.height);
        _headerView = headerView;
    }
    return _headerView;
}

- (MDTabView *)tabView {
    if (!_tabView) {
        _tabView = [[MDTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        _tabView.count = self.viewControllers.count;
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
                [weakSelf.pageController childScrollViewDidScroll:scrollView];
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
