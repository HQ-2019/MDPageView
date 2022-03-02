//
//  MDPageViewController.h
//  MDPageView
//
//  Created by hq on 2022/2/22.
//

#import <UIKit/UIKit.h>

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
///  controller.viewScrollCallBack = ^(CGPoint contentOffset, CGSize contentSize, BOOL isDragging) {
///     NSLog(@"offset: %@  isDragging: %@", @(contentOffset.x), @(isDragging));
///  };
///  controller.viewWillChangedCallBack = ^(NSInteger toIndex, NSInteger fromIndex) {
///     NSLog(@"页面将要切换  %@ -> %@", @(fromIndex), @(toIndex));
///  };
///  controller.viewDidChangedCallBack = ^(NSInteger toIndex, NSInteger fromIndex) {
///     NSLog(@"页面切换完成  %@ -> %@", @(fromIndex), @(toIndex));
///  };
///
///  [controller updateViewControllers:self.viewControllers];
///  [controller showPageAtIndex:showIndex animated:NO];
/// @endcode
///
@interface MDPageViewController : UIViewController

/// 视图滚动时回调相关数据
/// @param contentOffset 滚动视图位置偏移信息
/// @param contentSize 滚动视图内容size
/// @param isDragging 是否是手指拖动 YES-是
@property (nonatomic, copy) void(^viewScrollCallBack)(CGPoint contentOffset, CGSize contentSize, BOOL isDragging);

/// 子页面切换完成回调
/// @param toIndex 前往的页面索引
/// @param fromIndex 上一个显示的页面的索引
@property (nonatomic, copy) void(^viewWillChangedCallBack)(NSInteger toIndex, NSInteger fromIndex);

/// 子页面切换完成回调
/// @param toIndex 前往的页面索引
/// @param fromIndex 上一个显示的页面的索引
@property (nonatomic, copy) void(^viewDidChangedCallBack)(NSInteger toIndex, NSInteger fromIndex);

/// 设置更新控制器列表
/// 如果是重置，当发现原控制器无法释放时，检查传入的viewControllers是否被外部持有，如果是先执行viewControllers = nil或者viewControllers = newViewControllers；
/// @param viewControllers 控制器列表
- (void)updateViewControllers:(nullable NSArray<UIViewController *> *)viewControllers;

/// 显示指定位置的页面
/// 应在调用[updateViewControllers:]之后使用本方法
/// @param index 页面索引
/// @param animated 是否动画（如果开启动画，则自定义视图动画直线滑动效果）
- (void)showPageAtIndex:(NSInteger)index animated:(BOOL)animated;

/// 获取页面总数
- (NSInteger)pageCount;

/// 获取当前页面控制器索引
- (NSInteger)currentPageIndex;

/// 获取索引对应的视图控制器
/// @param index 索引
- (UIViewController *)viewControllerAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
