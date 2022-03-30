//
//  MDPageViewController.h
//  MDPageView
//
//  Created by hq on 2022/2/22.
//

#import <UIKit/UIKit.h>
#import "MDBaseScrollView.h"

NS_ASSUME_NONNULL_BEGIN

/// 页面控制器容器组件：
/// 支持页面切换后时预加载前后相邻的页面、
/// 支持点击跨多个页面切换时只显示当前页和目标页的动画、
/// 支持重置子控制器列表、
///
/// @code
///  // 用例
///  MDPageViewController *controller = [MDPageViewController new];
///  [self addChildViewController:controller];
///  [self.view addSubview:controller.view];
///  [controller didMoveToParentViewController:self];
///
///  controller.pageScrollViewDidScrolling = ^(CGPoint contentOffset, CGSize contentSize, BOOL isDragging) {
///     NSLog(@"offset: %@  isDragging: %@", @(contentOffset.x), @(isDragging));
///  };
///  controller.childViewWillChanged = ^(NSInteger appearIndex, NSInteger disappearIndex) {
///     NSLog(@"页面将要切换  %@ -> %@", @(disappearIndex), @(appearIndex));
///  };
///  controller.childViewDidChanged = ^(NSInteger appearIndex, NSInteger disappearIndex) {
///     NSLog(@"页面切换完成  %@ -> %@", @(disappearIndex), @(appearIndex));
///  };
///
///  [controller updateViewControllers:self.viewControllers];
///  [controller showPageAtIndex:showIndex animated:NO];
/// @endcode
///
@interface MDPageViewController : UIViewController

/// 上下滑动的滚动容器视图，即最底层的滚动容器视图
@property (nonatomic, strong, readonly) MDBaseScrollView *baseScrollView;

/// 上下滑动的滚动容器视图滚动时回调
/// @param scrollView 滚动视图
@property (nonatomic, copy) void(^baseScrollViewDidScrolling)(MDBaseScrollView *scrollView);

/// 左右滑动的页面滚动容器视图滚动时回
/// @param contentOffset 滚动视图位置偏移信息
/// @param contentSize 滚动视图内容size
/// @param isDragging 是否是手指拖动 YES-是
@property (nonatomic, copy) void(^pageScrollViewDidScrolling)(CGPoint contentOffset, CGSize contentSize, BOOL isDragging);

/// 子页面切换完成回调
/// @param appearIndex 将要显示页面索引
/// @param disappearIndex 将要消失页面的索引
@property (nonatomic, copy) void(^childViewWillChanged)(NSInteger appearIndex, NSInteger disappearIndex);

/// 子页面切换完成回调
/// @param appearIndex 完成显示页面索引
/// @param disappearIndex 完成消失页面的索引
@property (nonatomic, copy) void(^childViewDidChanged)(NSInteger appearIndex, NSInteger disappearIndex);

/// （必须设置）设置更新控制器列表
/// 如果是重置，当发现原控制器无法释放时，检查传入的viewControllers是否被外部持有，如果是先执行viewControllers = nil或者viewControllers = newViewControllers；
/// 如何要设置headerView或者subHeaderView，那么初始viewControllers中的ViewController后需要记录其的列表到self.childScrollView上，并且子列表滚动时将其滚动事件回调到本组件中
/// @param viewControllers 控制器列表
- (void)updateViewControllers:(nullable NSArray<UIViewController *> *)viewControllers;

/// 显示指定位置的页面
/// 应在调用[updateViewControllers:]之后使用本方法
/// @param index 页面索引
/// @param animated 是否动画（如果开启动画，则自定义视图动画直线滑动效果）
- (void)showPageAtIndex:(NSInteger)index animated:(BOOL)animated;

/// 设置headerView
/// @param headerView headerView
- (void)updateHeaderView:(UIView *)headerView;

/// 设置吸附在顶部的视图
/// @param subHeaderView subHeaderView
- (void)updateSubHeaderView:(UIView *)subHeaderView;

/// 获取页面总数
- (NSInteger)pageCount;

/// 获取当前页面控制器索引
- (NSInteger)currentPageIndex;

/// 获取当前显示的视图控制器
- (nullable UIViewController *)currentViewController;

/// 获取索引对应的视图控制器
/// @param index 索引
- (nullable UIViewController *)viewControllerAtIndex:(NSInteger)index;

/// 接收子页面控制器中滚动列表视图的滚动信息
/// 当设置了headerView或subHeaderView后，子视图滚动需调此方法将子列表传入进行位置移动计算
/// @param scrollView 子页面滚动列表
- (void)childScrollViewDidScroll:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
