//
//  MDPageViewController2.m
//  MDPageView
//
//  Created by hq on 2022/2/18.
//

#import "MDPageViewController2.h"

@interface MDPageViewController2 () <UIScrollViewDelegate>

/// 底部滚动视图
@property (nonatomic, strong) UIScrollView *baseScrollView;
/// 视图控制器列表
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
/// 当前展示视图在列表中的的index
@property (nonatomic, assign) NSInteger index;
/// 将要展示视图在列表中的index
@property (nonatomic, assign) NSInteger toIndex;

/// 手指开始滑动时x轴上的偏移量
@property (nonatomic, assign) CGFloat startX;

/// 滑动方向 1左 2右
@property (nonatomic, assign) NSInteger fangxiang;

/// 页面预加载方案
@property (nonatomic, assign) MDPreloadType preloadType;

/// 标记baseScrollView内容设置几个，用于计算contentSize的宽度
@property (nonatomic, assign) NSInteger contentCount;

@end

@implementation MDPageViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
}

/// （关键）不自动调用子控制器的生命周期方法
- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (UIScrollView *)baseScrollView {
    if (!_baseScrollView) {
        _baseScrollView = [[UIScrollView alloc] init];
        _baseScrollView.delegate = self;
        _baseScrollView.bounces = NO;
        _baseScrollView.pagingEnabled = YES;
        _baseScrollView.showsVerticalScrollIndicator = NO;
        _baseScrollView.showsHorizontalScrollIndicator = NO;
        _baseScrollView.frame = self.view.bounds;
        [self.view addSubview:_baseScrollView];
    }
    return _baseScrollView;
}

/// 设置控制器列表
/// @param viewControllers 控制器列表
/// @param index 要展示的页面索引
/// @param preloadType 页面预加载策略
- (void)setViewControllers:(nullable NSArray<UIViewController *> *)viewControllers
                     index:(NSInteger)index
               preloadTyoe:(MDPreloadType)preloadType {
    self.viewControllers = viewControllers;
    self.preloadType = preloadType;
    self.index = index;
    self.toIndex = index;
    
    // 清空已加载的子视图
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.view removeFromSuperview];
        [obj removeFromParentViewController];
    }];
    
    [self.baseScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 计算滚动视图内容页数
    if (self.preloadType == MDPreloadType_All || self.viewControllers.count <= 3) {
        self.contentCount = self.viewControllers.count;
    } else {
        self.contentCount = 3;
    }
    self.baseScrollView.contentSize = CGSizeMake(self.contentCount * self.baseScrollView.bounds.size.width, self.baseScrollView.bounds.size.height);
    
    // 添加控制器
    [self addChildViewControllers:index];
    
    // 视图内容布局
    [self updateScrollerContent];
}

- (void)addChildViewControllers:(NSInteger)index {
    switch (self.preloadType) {
        case MDPreloadType_None: {
            [self addChildViewController:self.viewControllers[index] isShow:YES];
        }
            break;
        case MDPreloadType_BeforeAndAfter: {
            [self addChildViewController:self.viewControllers[index] isShow:YES];
            
            // 预加载前一个
            if (index - 1 <= 0) {
                [self addChildViewController:self.viewControllers[index - 1] isShow:NO];
            }
            
            // 预加载后一个
            if (index + 1 < self.viewControllers.count) {
                [self addChildViewController:self.viewControllers[index + 1] isShow:NO];
            }
        }
            break;
        case MDPreloadType_All: {
            [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull controller, NSUInteger idx, BOOL * _Nonnull stop) {
                [self addChildViewController:controller isShow:index == idx];
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)addChildViewController:(UIViewController *)childController isShow:(BOOL)isShow{
    [self addChildViewController:childController];
    [childController willMoveToParentViewController:self];
    [self.baseScrollView addSubview:childController.view];
    [childController didMoveToParentViewController:self];
    
    if (isShow) {
        
        [childController beginAppearanceTransition:YES animated:YES];
        [childController endAppearanceTransition];
    }
}

- (void)removeSubViewController:(UIViewController *)childController {
    [childController willMoveToParentViewController:self];
    [childController.view removeFromSuperview];
    [childController removeFromParentViewController];
}

/// 更新滚动视图上的内容
- (void)updateScrollerContent {
    // 添加视图
    switch (self.preloadType) {
        case MDPreloadType_None: {
            NSInteger xIndex = 0;
            if (self.viewControllers.count > 3) {
                xIndex = 1;
            } else if (self.viewControllers.count == 2) {
                xIndex = self.index == 2 ? 1 : 0;
            } else {
                xIndex = 0;
            }
            
            UIViewController *controller = self.viewControllers[self.index];
            [self setFrameView:controller.view index:xIndex];
            [self.baseScrollView setContentOffset:CGPointMake(self.baseScrollView.bounds.size.width * xIndex, 0) animated:NO];
        }
            break;
        case MDPreloadType_BeforeAndAfter: {
            UIViewController *controller = self.viewControllers[self.index];
            [self setFrameView:controller.view index:self.index != 0 ? 1 : 0];
            [self.baseScrollView setContentOffset:CGPointMake(self.baseScrollView.bounds.size.width * self.index, 0) animated:NO];
            
            // 预加载前一个
            if (self.index - 1 >= 0) {
                UIViewController *controller1 = self.viewControllers[self.index - 1];
                [self setFrameView:controller1.view index:0];
            }
            
            // 预加载后一个
            if (self.index + 1 < self.viewControllers.count) {
                UIViewController *controller1 = self.viewControllers[self.index + 1];
                [self setFrameView:controller1.view index:2];
            }
        }
            break;
        case MDPreloadType_All: {
            [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull controller, NSUInteger idx, BOOL * _Nonnull stop) {
                [self setFrameView:controller.view index:idx];
            }];
            [self.baseScrollView setContentOffset:CGPointMake(self.baseScrollView.bounds.size.width * self.index, 0) animated:NO];
        }
            break;
            
        default:
            break;
    }
}

- (void)setFrameView:(UIView *)view index:(NSInteger)index {
    view.frame = CGRectMake(index * self.baseScrollView.bounds.size.width, 0, self.baseScrollView.bounds.size.width, self.baseScrollView.bounds.size.height);
}


/// 滚动到指定索引的页面
/// @param toIndex 页面索引
/// @param animated 是否动画
- (void)scrollToIndex:(NSInteger)toIndex animated:(BOOL)animated {
    // 如果toIndex页面和当前页面不是相邻的，需要将toIndex页面先替换到相邻页面上
    [self.baseScrollView setContentOffset:CGPointMake(self.baseScrollView.bounds.size.width * toIndex, 0) animated:animated];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

/// 列表滚动中 （需要实时计算并回调索引的变更）
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.panGestureRecognizer.view.superview];
//    if (translation.x > 0) {
//        //右滑
////        toIndex = floor(scrollView.contentOffset.x / pageWidth);
//        NSLog(@"向右划");
//        self.fangxiang = 2;
//    } else {
//        //左滑
////        toIndex = ceil(scrollView.contentOffset.x / pageWidth);
//        NSLog(@"向左划");
//        self.fangxiang = 1;
//    }
    
//    //
//    if (scrollView.contentOffset.x > self.startX) {
//        // 页面向右划去
//        CGFloat page = (scrollView.contentOffset.x - self.startX) / (CGFloat)self.baseScrollView.bounds.size.width;
//        if (page == 1) {
//
//        }
//    } else if(scrollView.contentOffset.x > self.startX) {
//        // 页面向左划去
//    }

    NSLog(@"isTracking: %@   isDecelerating: %@   isDragging: %@", @(scrollView.isTracking), @(scrollView.isDecelerating), @(scrollView.isDragging));
}

/// 列表即将开始滚动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"即将 滚动");
    self.startX = scrollView.contentOffset.x;
//    NSLog(@"xxxxxxx  %@", @(self.startX));
}

/// 自动滚动结束时,即调用scrollToItemAtIndexPath:atScrollPosition:animated并且animated为YES时
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEnd:scrollView animations:NO];
    NSLog(@"自动滚动 结束");
}

/// 手指拖动引起的滚动结束时
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEnd:scrollView animations:NO];
    NSLog(@"手指拖动滚动 结束");
    NSInteger xIndex;
    if (self.fangxiang == 1) {
        xIndex = MIN(self.viewControllers.count - 1, self.index + 1);
    } else {
        xIndex = MAX(0, self.index - 1);
    }
    
    if (xIndex != self.index) {
        self.index = xIndex;
        NSMutableArray<UIViewController *> *controllers = @[].mutableCopy;
        NSMutableArray<UIView *> *views = @[].mutableCopy;
        if (self.index - 1 >= 0) {
            [controllers addObject:self.viewControllers[self.index - 1]];
        }
        [controllers addObject:self.viewControllers[self.index]];
        if (self.index + 1 < self.viewControllers.count) {
            [controllers addObject:self.viewControllers[self.index + 1]];
        }
        
        [controllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self.childViewControllers containsObject:obj]) {
                [self addChildViewController:obj isShow:NO];
            }
            if (![self.baseScrollView.subviews containsObject:obj.view]) {
                [self.baseScrollView addSubview:obj.view];
            }
            [views addObject:obj.view];
        }];
    
        [self.baseScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![views containsObject:obj]) {
                [obj removeFromSuperview];
                [self removeSubViewController:self.viewControllers[obj.tag]];;
            }
        }];
        
        [controllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self.baseScrollView.subviews containsObject:obj.view]) {
                [self addChildViewController:obj isShow:idx == 1];
            }
            [self setFrameView:obj.view index:idx];
        }];
        
        [self updateContentOffset:NO];
//        [self updateContentSize];
    }
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"xxxxxxxxx");
}

/// 手指离开了列表
/// decelerate为YES时列表会惯性滑动， 为NO时列表直接静止
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollViewDidEnd:scrollView animations:YES];
        NSLog(@"33333333333333");
    }
    NSLog(@"2222222222222222");
}

/// 列表最终滚动结束时
- (void)scrollViewDidEnd:(UIScrollView *)scrollView animations:(BOOL)animations {
    NSInteger page = scrollView.contentOffset.x < scrollView.bounds.size.width ? 0 : scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    if (scrollView.contentOffset.x < scrollView.bounds.size.width) {
        page = 0;
    } else {
        page = scrollView.contentOffset.x / scrollView.bounds.size.width;
        
    }
}


- (void)setIndex:(NSInteger)index {
    // 记录之前的index
    NSInteger lastIndex = _index;
    _index = index;
}

- (void)updateContentSize {
    CGFloat width = MIN(self.baseScrollView.bounds.size.width, self.baseScrollView.subviews.count * self.baseScrollView.bounds.size.width);
    [self.baseScrollView setContentSize:CGSizeMake(width, self.baseScrollView.bounds.size.height)];
}

- (void)updateContentOffset:(BOOL)animations {
    CGFloat x = self.index == 0 ? 0 : self.baseScrollView.bounds.size.width;
    [self.baseScrollView setContentOffset:CGPointMake(x, 0) animated:NO];
}

@end
