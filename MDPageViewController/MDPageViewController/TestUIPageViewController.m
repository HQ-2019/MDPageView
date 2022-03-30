//
//  TestUIPageViewController.m
//  MDPageViewController
//
//  Created by hq on 2022/2/24.
//

#import "TestUIPageViewController.h"
#import "MDSubViewController.h"
#import "MDTabView.h"

@interface TestUIPageViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) MDTabView *tabView;
@property (nonatomic, strong) NSArray *viewControllers;

@end

@implementation TestUIPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"UIPageViewController";
    
    __weak typeof(self) weakSelf = self;
    NSInteger showIndex = 1;
    
    [self.pageViewController setViewControllers:@[self.viewControllers[showIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
//    [self addChildViewController:self.pageViewController];
//    [self.view addSubview:self.pageViewController.view];
//    [self.pageViewController didMoveToParentViewController:self];
    
    
    [self.tabView showAtIndex:showIndex];
    self.tabView.clickIndexBlock = ^(NSInteger index) {
        [weakSelf.pageViewController setViewControllers:@[weakSelf.viewControllers[index]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    };
}

- (UIPageViewController *)pageViewController {
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        [self addChildViewController:self.pageViewController];
        [self.view addSubview:self.pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
    }
    
    return _pageViewController;
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
        NSMutableArray *xx = @[].mutableCopy;
        [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MDSubViewController *controller = [MDSubViewController new];
            controller.content = [NSString stringWithFormat:@"页面： %@", @(idx)];
            controller.color = obj;
            [xx addObject:controller];
        }];
        
        _viewControllers = [NSArray arrayWithArray:xx];
    }
    return _viewControllers;
}

#pragma mark -
#pragma mark - UIPageViewControllerDataSource
/// 返回前一个页面
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    
    index --;
    
    return self.viewControllers[index];
}

/// 返回下一个页面
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    if (index >= self.viewControllers.count - 1 || index == NSNotFound) {
        return nil;
    }
    
    index ++;
    
    return self.viewControllers[index];
}

#pragma mark -
#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    NSInteger index = [self.viewControllers indexOfObject:pendingViewControllers.firstObject];
    [self.tabView showAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (!completed) {
        NSInteger index = [self.viewControllers indexOfObject:previousViewControllers.firstObject];
        [self.tabView showAtIndex:index];
    }
}


@end
