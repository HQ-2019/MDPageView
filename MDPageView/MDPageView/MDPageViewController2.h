//
//  MDPageViewController2.h
//  MDPageView
//
//  Created by hq on 2022/2/18.
//

#import <UIKit/UIKit.h>

/// 预加载策略
typedef NS_ENUM(NSInteger, MDPreloadType) {
    MDPreloadType_None,             ///< 不预加载 只加载当前显示的页面
    MDPreloadType_BeforeAndAfter,   ///< 预加载当前页面的前一个和后一个页面
    MDPreloadType_All,              ///< 预加载所有页面
};

NS_ASSUME_NONNULL_BEGIN

@interface MDPageViewController2 : UIViewController

/// 设置控制器列表
/// @param viewControllers 控制器列表
/// @param index 要展示的页面索引
/// @param preloadType 页面预加载策略
- (void)setViewControllers:(nullable NSArray<UIViewController *> *)viewControllers
                     index:(NSInteger)index
               preloadTyoe:(MDPreloadType)preloadType;

/// 滚动到指定索引的页面
/// @param toIndex 页面索引
/// @param animated 是否动画
- (void)scrollToIndex:(NSInteger)toIndex animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
