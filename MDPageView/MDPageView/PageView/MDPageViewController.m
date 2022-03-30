//
//  MDPageViewController.m
//  MDPageView
//
//  Created by hq on 2022/2/22.
//


#import "MDPageViewController.h"
#import "UIViewController+md.h"

@interface MDPageViewController () <UIScrollViewDelegate>

/// 上下滑动的滚动容器视图，即最底层的滚动容器视图
@property (nonatomic, strong) MDBaseScrollView *baseScrollView;

/// 左右滑动的页面滚动容器视图
@property (nonatomic, strong) UIScrollView *pageScrollView;

/// 当前展示的子页面上的列表视图
@property (nonatomic, strong, nullable) UIScrollView *childScrollView;

/// 头视图
@property (nonatomic, strong, nullable) UIView *headerView;

/// 悬浮头视图，即向上滑动列表是吸附在最顶部的头视图
@property (nonatomic, strong, nullable) UIView *subHeaderView;

/// 视图控制器列表
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;

/// 已添加的视图控制器索引（用于在页面切换结束后移除非相邻的页面）
@property (nonatomic, strong) NSMutableArray<NSNumber *> *addedVCIndexs;

/// 页面总数
@property (nonatomic, assign) NSInteger pageCount;

/// 当前显示视图在列表中的索引，默认值：-1
@property (nonatomic, assign) NSInteger currentPageIndex;

/// 上一次显示视图的索引，默认值：-1
@property (nonatomic, assign) NSInteger lastPageIndex;

/// 手势拖动时将要前往页面的索引，默认值：-1
@property (nonatomic, assign) NSInteger toPageIndex;

/// 标记容器页面是否完成首次的viewDidDisappear
@property (nonatomic, assign) BOOL didAppear;

/// 切换页面或上下滚动时记录底部滚动容器内容偏移的位置
@property (nonatomic, assign) CGPoint baseScrollViewOffset;

/// 切换页面或上下滚动时记录子页面列表内容偏移的位置
@property (nonatomic, assign) CGPoint childScrollViewOffset;

/// 记录底部滚动容器上一次滑动速率不等于0时的速率，用于当前速率等于0时区分出当前视图的滚动方向，即使用上一次的速率来判断
@property (nonatomic, assign) CGPoint baseScrollViewVelocity;

@end

@implementation MDPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toPageIndex = -1;
    self.lastPageIndex = -1;
    self.currentPageIndex = -1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.didAppear) {
        [[self viewControllerAtIndex:self.currentPageIndex] beginAppearanceTransition:YES animated:YES];
        !self.childViewWillChanged ?: self.childViewWillChanged(self.currentPageIndex , -1);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.didAppear) {
        [[self viewControllerAtIndex:self.currentPageIndex] endAppearanceTransition];
        !self.childViewDidChanged ?: self.childViewDidChanged(self.currentPageIndex , -1);
    }
    
    self.didAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.didAppear) {
        [[self viewControllerAtIndex:self.currentPageIndex] beginAppearanceTransition:NO animated:YES];
        !self.childViewWillChanged ?: self.childViewWillChanged(-1 , self.currentPageIndex);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.didAppear) {
        [[self viewControllerAtIndex:self.currentPageIndex] endAppearanceTransition];
        !self.childViewDidChanged ?: self.childViewDidChanged(-1 , self.currentPageIndex);
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.subHeaderView) {
        CGRect rect = self.pageScrollView.frame;
        rect.size.height = rect.size.height - self.subHeaderView.bounds.size.height;
        self.pageScrollView.frame = rect;
    }
    
    // 更新列表容器
    [self updateScrollViewContentSize];
    [self updateScrollViewContentOffset:NO];
}

/// （关键）不自动调用子控制器的生命周期方法
- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

/// 已添加的视图控制器索引（用于在页面切换结束后移除非相邻的页面）
- (NSMutableArray<NSNumber *> *)addedVCIndexs {
    if (!_addedVCIndexs) {
        _addedVCIndexs = @[].mutableCopy;
    }
    return _addedVCIndexs;
}

/// 滚动视图(视图容器)
- (MDBaseScrollView *)baseScrollView {
    if (!_baseScrollView) {
        _baseScrollView = [[MDBaseScrollView alloc] init];
        _baseScrollView.delegate = self;
        _baseScrollView.bounces = YES;
        _baseScrollView.showsVerticalScrollIndicator = NO;
        _baseScrollView.showsHorizontalScrollIndicator = NO;
        _baseScrollView.frame = self.view.bounds;
        _baseScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_baseScrollView];
        if (@available(iOS 11.0, *)) {
            _baseScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
    return _baseScrollView;
}

/// 滚动视图(视图容器)
- (UIScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[UIScrollView alloc] init];
        _pageScrollView.delegate = self;
        _pageScrollView.bounces = NO;
        _pageScrollView.pagingEnabled = YES;
        _pageScrollView.showsVerticalScrollIndicator = NO;
        _pageScrollView.showsHorizontalScrollIndicator = NO;
        _pageScrollView.frame = CGRectMake(0, self.headerView.frame.size.height + self.subHeaderView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
        _pageScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.baseScrollView addSubview:_pageScrollView];
        if (@available(iOS 11.0, *)) {
            _pageScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _pageScrollView;
}

/// 当前显示视图的索引
- (NSInteger)currentPageIndex {
    return _currentPageIndex;
}

/// 获取页面总数
- (NSInteger)pageCount {
    return self.viewControllers.count;
}

/// 获取当前显示的视图控制器
- (nullable UIViewController *)currentViewController {
    return [self viewControllerAtIndex:self.currentPageIndex];
}

/// 获取索引对应的视图控制器
/// @param index 索引
- (nullable UIViewController *)viewControllerAtIndex:(NSInteger)index {
    return index < 0 || index >= self.viewControllers.count ? nil : self.viewControllers[index];
}

/// 设置headerView
/// @param headerView headerView
- (void)updateHeaderView:(UIView *)headerView {
    if (self.headerView != headerView) {
        if (self.headerView) {
            [self.headerView removeFromSuperview];
        }
        
        self.headerView = headerView;
        [self.baseScrollView addSubview:self.headerView];
    }
}

/// 设置吸附在顶部的视图
/// @param subHeaderView headerView
- (void)updateSubHeaderView:(UIView *)subHeaderView {
    if (self.subHeaderView != subHeaderView) {
        if (self.subHeaderView) {
            [self.subHeaderView removeFromSuperview];
        }
        
        self.subHeaderView = subHeaderView;
        CGRect rect = subHeaderView.bounds;
        rect.origin.y = self.headerView.bounds.size.height;
        self.subHeaderView.frame = rect;
        [self.baseScrollView addSubview:self.subHeaderView];
    }
}

#pragma mark -
#pragma mark - 更新视图和控制器

/// （必须设置）设置更新控制器列表
/// 如果是重置，当发现原控制器无法释放时，检查传入的viewControllers是否被外部持有，如果是先执行viewControllers = nil或者viewControllers = newViewControllers；
/// 如何要设置headerView或者subHeaderView，那么初始viewControllers中的ViewController后需要记录其的列表到self.childScrollView上，并且子列表滚动时将其滚动事件回调到本组件中
/// @param viewControllers 控制器列表
- (void)updateViewControllers:(nullable NSArray<UIViewController *> *)viewControllers {
    
    // 清空旧页面
    if (self.currentPageIndex > 0) {
        [self viewWillChange:-1 fromeIndex:self.currentPageIndex];
        [self viewDidChange:self.currentPageIndex fromeIndex:-1];
        [self removeAllViewController];
        
        self.toPageIndex = -1;
        self.lastPageIndex = -1;
        self.currentPageIndex = -1;
    }
    
    // 记录子控制器列表
    self.viewControllers = viewControllers;
    
    // 更新列表容器
    [self updateScrollViewContentSize];
    [self updateScrollViewContentOffset:NO];
}

/// 显示指定位置的页面
/// 应在调用[updateViewControllers:]之后使用本方法
/// @param index 页面索引
/// @param animated 是否动画（如果开启动画，则自定义视图动画直线滑动效果）
- (void)showPageAtIndex:(NSInteger)index animated:(BOOL)animated {
    
    if (self.viewControllers.count <= 0) {
        NSLog(@"请先执行[updateViewControllers:]设置子控制器列表");
        return;
    }
    
    if (index < 0 || index >= self.viewControllers.count) {
        NSLog(@"请正确设置页面索引，有效值应在范围 %@~%@", @(0), @(self.viewControllers.count - 1));
        return;
    }
    
    if (index == self.currentPageIndex) {
        return;
    }
    
    // 记录索引
    NSInteger oldPageIndex = self.lastPageIndex;
    self.lastPageIndex = self.currentPageIndex;
    self.currentPageIndex = index;
    
    // 添加当前索引对应视图
    [self addChildViewControllerWithIndex:index];
    
    // 滚动准备开始
    void (^scrollBeginAnimation)(void) = ^(void) {
        // 视图将要切换
        [self viewWillChange:self.currentPageIndex fromeIndex:self.lastPageIndex];
    };
    
    // 滚动结束
    void (^scrollEndAnimation)(void) = ^(void) {
        // 更新视图内容位置
        [self updateScrollViewContentOffset:NO];
        
        // 视图完成切换
        [self viewDidChange:self.currentPageIndex fromeIndex:self.lastPageIndex];
        
        // 将非相邻视图移除
        [self removeNotNeighbourViewController];
        
        // 预加载相邻视图
        [self addNeighbourViewControllerWithIndex:self.currentPageIndex];
        
    };
    
    // ********************** 未启用动画切换
    if (!animated) {
        // 执行准备滚动
        scrollBeginAnimation();
        // 直接切换，不执行动画
        scrollEndAnimation();
        
        return;
    }
    
    // ********************** 启用动画切换
    
    // 页面视图的size
    CGSize pageSize = self.pageScrollView.frame.size;
    
    // 动画页面
    UIView *oldView = [self viewControllerAtIndex:oldPageIndex].view;
    UIView *lastView = [self viewControllerAtIndex:self.lastPageIndex].view;
    UIView *currentView = [self viewControllerAtIndex:self.currentPageIndex].view;
    
    UIView *backgroundView = nil;
    // 用户快速点击切换页面，即前一次切换动画未结束时，又发起了新的页面切换
    // 触发他们完成页面生命周期调用，将要消失的视图要及时切换
    if (oldView.layer.animationKeys.count > 0 && lastView.layer.animationKeys.count > 0) {
        
        // 视图完成切换
        [self viewDidChange:self.lastPageIndex fromeIndex:oldPageIndex];
        
        UIView *tmepView = [self viewControllerAtIndex:self.pageScrollView.contentOffset.x / pageSize.width].view;
        if (tmepView != currentView && tmepView != lastView) {
            backgroundView = tmepView;
            [UIView animateWithDuration:2 animations:^{
                backgroundView.hidden = YES;
            }];
        }
    }
    
    // 执行准备滚动
    scrollBeginAnimation();
    
    // 移除当前在执行的动画（用户可能在快速点击切换）
    [self.pageScrollView.layer removeAllAnimations];
    [oldView.layer removeAllAnimations];
    [lastView.layer removeAllAnimations];
    [currentView.layer removeAllAnimations];
    
    // 恢复oldView的坐标
    [self moveBackToOriginPositionIfNeeded:oldView index:oldPageIndex];
    
    // 将执行动画的视图层级提到前面，避免遮挡
    [self.pageScrollView bringSubviewToFront:lastView];
    [self.pageScrollView bringSubviewToFront:currentView];
    
    // 计算执行动画的视图的开始,移动目标和结束时的位置
    CGPoint lastView_StartOrigin = lastView.frame.origin;
    CGPoint lastView_MoveToOrigin = lastView.frame.origin;
    CGPoint lastView_EndOrigin = lastView.frame.origin;
    
    CGPoint currtentView_StartOrigin = lastView.frame.origin;
    CGPoint currtentView_MoveToOrigin = lastView.frame.origin;
    CGPoint currtentView_EndOrigin = currentView.frame.origin;
    
    // 根据滚动方向调整视图的x坐标
    if (self.lastPageIndex < self.currentPageIndex) {
        currtentView_StartOrigin.x += pageSize.width;
        lastView_MoveToOrigin.x -= pageSize.width;
    } else {
        currtentView_StartOrigin.x -= pageSize.width;
        lastView_MoveToOrigin.x += pageSize.width;
    }
    
    // 调整动画的两个视图frame到相邻位置
    lastView.frame = CGRectMake(lastView_StartOrigin.x, lastView_StartOrigin.y, pageSize.width, pageSize.height);
    currentView.frame = CGRectMake(currtentView_StartOrigin.x, currtentView_StartOrigin.y, pageSize.width, pageSize.height);
    
    // 执行页面切换动画
    [UIView animateWithDuration:0.3 animations:^{
        lastView.frame = CGRectMake(lastView_MoveToOrigin.x, lastView_MoveToOrigin.y, pageSize.width, pageSize.height);
        currentView.frame = CGRectMake(currtentView_MoveToOrigin.x, currtentView_MoveToOrigin.y, pageSize.width, pageSize.height);
    } completion:^(BOOL finished) {
        if (finished) {
            lastView.frame = CGRectMake(lastView_EndOrigin.x, lastView_EndOrigin.y, pageSize.width, pageSize.height);
            currentView.frame = CGRectMake(currtentView_EndOrigin.x, currtentView_EndOrigin.y, pageSize.width, pageSize.height);
            
            backgroundView.hidden = NO;
            
            // 恢复视图坐标
            [self moveBackToOriginPositionIfNeeded:currentView index:self.currentPageIndex];
            [self moveBackToOriginPositionIfNeeded:lastView index:self.lastPageIndex];
            
            // 动画结束
            scrollEndAnimation();
        }
    }];
}

/// 计算索引对应视图的frame
/// @param index 视图索引
- (CGRect)calcChildViewFrameWithIndex:(NSInteger)index {
    CGFloat x = index * (CGFloat)self.pageScrollView.frame.size.width;
    return CGRectMake(x, 0, self.pageScrollView.bounds.size.width, self.pageScrollView.bounds.size.height);
}

/// 计算索引对应的offSet
/// @param index 视图索引
- (CGPoint)calcOffsetWithIndex:(NSInteger)index {
    CGFloat width = (CGFloat)self.pageScrollView.frame.size.width;
    CGFloat maxWidth = (CGFloat)self.pageScrollView.contentSize.width;
    CGFloat offsetX = MAX(0, index * width);
    
    if (maxWidth > 0.0 && offsetX > maxWidth - width) {
        offsetX = maxWidth - width;
    }
    
    return CGPointMake(offsetX, 0);
}

/// 更新滚动视图内容size
- (void)updateScrollViewContentSize {
    CGFloat width = MAX(self.pageScrollView.bounds.size.width, self.pageCount * self.pageScrollView.bounds.size.width);
    CGSize size = CGSizeMake(width, 0);
    
    if (!CGSizeEqualToSize(size, self.pageScrollView.contentSize)) {
        [self.pageScrollView setContentSize: size];
    }
    
    if (self.headerView || self.subHeaderView) {
        CGFloat height = self.headerView.frame.size.height + self.subHeaderView.frame.size.height + self.pageScrollView.frame.size.height;
        if (height <= self.baseScrollView.bounds.size.height) {
            height = self.baseScrollView.bounds.size.height + 1;
        }
        CGSize size1 = CGSizeMake(0, height);
        if (!CGSizeEqualToSize(size1, self.baseScrollView.contentSize)) {
            [self.baseScrollView setContentSize: size1];
        }
    }
}

/// 更新视图内容位置
/// @param animations 是否开始动画
- (void)updateScrollViewContentOffset:(BOOL)animations {
    CGFloat x = MAX(self.currentPageIndex * self.pageScrollView.bounds.size.width, 0);
    CGPoint offset = CGPointMake(x, 0);
    if (!CGPointEqualToPoint(offset, self.pageScrollView.contentOffset)) {
        [self.pageScrollView setContentOffset:offset animated:animations];
    }
}

/// 添加与索引相邻的视图
/// @param index 索引
- (void)addNeighbourViewControllerWithIndex:(NSInteger)index {
    [self addChildViewControllerWithIndex:index - 1];
    [self addChildViewControllerWithIndex:index + 1];
}

/// 添加视图控制器
/// @param index 索引
- (void)addChildViewControllerWithIndex:(NSInteger)index {
    UIViewController *controller = [self viewControllerAtIndex:index];
    if (!controller) {
        return;
    }
    BOOL isContainsVC = [self.childViewControllers containsObject:controller];
    if (!isContainsVC) {
        [self addChildViewController:controller];
    }
    
    controller.view.frame = [self calcChildViewFrameWithIndex:index];
    controller.view.hidden = NO;
    if (![self.pageScrollView.subviews containsObject:controller.view]) {
        [self.pageScrollView addSubview:controller.view];
    }
    
    if (!isContainsVC) {
        [controller didMoveToParentViewController:self];
    }
    
    // 记录已添加页面的索引
    NSNumber *indexNum = @(index);
    if (![self.addedVCIndexs containsObject:indexNum]) {
        [self.addedVCIndexs addObject:indexNum];
    }
}

/// 移除视图控制器
/// @param index 索引
- (void)removeChildViewControllerWithIndex:(NSInteger)index {
    UIViewController *controller = [self viewControllerAtIndex:index];
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

/// 移除非相邻视图控制器
- (void)removeNotNeighbourViewController {
    NSArray<NSNumber *> *remove = [self.addedVCIndexs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSNumber *  _Nullable obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSInteger index = obj.integerValue;
        return self.currentPageIndex != index && self.currentPageIndex - 1 != index && self.currentPageIndex + 1 != index;
    }]];
    
    [remove enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeChildViewControllerWithIndex:obj.integerValue];
    }];
}

/// 清除所有添加过的视图控制器
- (void)removeAllViewController {
    [self.addedVCIndexs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeChildViewControllerWithIndex:obj.integerValue];
    }];
    self.addedVCIndexs = nil;
}

/// 将视图位置移动到原始位置
/// @param view 视图
/// @param index 视图控制器索引
- (void)moveBackToOriginPositionIfNeeded:(UIView *)view index:(NSInteger)index {
    if (index < 0 || index >= self.pageCount || view == nil) {
        return;
    }
    
    UIView *destView = view;
    CGPoint originPosition = [self calcOffsetWithIndex:index];
    if (destView.frame.origin.x != originPosition.x) {
        CGRect newFrame = destView.frame;
        newFrame.origin = originPosition;
        destView.frame = newFrame;
    }
}

/// 页面将要切换
/// @param toIndex 将要出现的页面
/// @param fromeIndex 将要消失的页面
- (void)viewWillChange:(NSInteger)toIndex fromeIndex:(NSInteger)fromeIndex {
    [[self viewControllerAtIndex:toIndex] beginAppearanceTransition:YES animated:YES];
    [[self viewControllerAtIndex:fromeIndex] beginAppearanceTransition:NO animated:YES];
    !self.childViewWillChanged ?: self.childViewWillChanged(toIndex , fromeIndex);
}

/// 页面完成切换
/// @param toIndex 刚出现的页面
/// @param fromeIndex 刚消失了的页面
- (void)viewDidChange:(NSInteger)toIndex fromeIndex:(NSInteger)fromeIndex {
    [[self viewControllerAtIndex:toIndex] endAppearanceTransition];
    [[self viewControllerAtIndex:fromeIndex] endAppearanceTransition];
    !self.childViewDidChanged ?: self.childViewDidChanged(toIndex , fromeIndex);
    
    // 页面切换完成后记录子页面列表和主容器列表内容偏移相关信息
    [self childViewDidChangedToIndex:toIndex];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate (处理子页面之间切换的计算逻辑)

/// 列表滚动中 （需要实时计算并回调索引的变更）
/// isDragging 表示滚动是否由用户手势滑动引起
/// isTracking 表示当前滚动是否是跟随手指的滑动
/// isDecelerating 表示正在减速滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.baseScrollView) {
        [self baseScrollViewDidScroll];
        return;
    }
    
    if (scrollView != self.pageScrollView) {
        return;
    }
    
    //    NSLog(@"isTracking: %@   isDecelerating: %@   isDragging: %@", @(scrollView.isTracking), @(scrollView.isDecelerating), @(scrollView.isDragging));
    
    // 回调滚动数据
    !self.pageScrollViewDidScrolling ?: self.pageScrollViewDidScrolling(scrollView.contentOffset, scrollView.contentSize, scrollView.isDragging);
    
    // 忽略由[setContentOffset:animated:]等非手势滑动引起的滚动
    if (!scrollView.isDragging && !scrollView.isTracking && !scrollView.isDecelerating) {
        return;
    }
    
    CGFloat offsetX = (CGFloat)scrollView.contentOffset.x;
    CGFloat pageWidth = (CGFloat)scrollView.frame.size.width;
    
    // 根据当前滑动方向实时计算将要前往的页面
    NSInteger newToPage = 0;
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.panGestureRecognizer.view.superview];
    if (translation.x <= 0) {
        newToPage = ceil(offsetX / pageWidth);
    } else {
        newToPage = floor(offsetX / pageWidth);
    }
    
    // 滑到了有效页面之外
    if (newToPage < 0 || newToPage >= self.pageCount) {
        return;
    }
    
    // 从页面静止状态开始滑动
    if (self.toPageIndex < 0) {
        
        // 向边界外滑动
        if (newToPage == self.currentPageIndex) {
            return;
        }
        
        self.toPageIndex = newToPage;
        self.lastPageIndex = self.currentPageIndex;
        
        // 新页面将要滑出
        [self addChildViewControllerWithIndex:self.toPageIndex];
        [self viewWillChange:self.toPageIndex fromeIndex:self.currentPageIndex];
        
        return;
    }
    
    // 滑动过程中，当newToPage不等于self.toPageIndex时，意味着newToPage为将要出现的页面，而self.toPageIndex为将要消失的页面
    if (newToPage != self.toPageIndex) {
        
        // 视图完成切换
        // 如从2->3，当3页面未完全显示时又从3->2，实际页面3未完全显示页面2未完全消失，因此不执行2->3的viewDidAppear/Disappear
        // 如从2->3->4，先将2->3结束再开始3->4生命周期，即执行2->3的viewDidAppear/Disappear
        if (self.currentPageIndex != newToPage) {
            [self viewDidChange:self.toPageIndex fromeIndex:self.currentPageIndex];
        }
        
        // 处理前后反复滑动时子页面生命周期触发缺失的问题（如从1往0滑再往2滑, 速度够快会出现此类问题）
        if (ABS(self.toPageIndex - newToPage) >= 2) {
            
            NSLog(@"跨页面切换");
            // 视图将要切换
            [self viewWillChange:self.currentPageIndex fromeIndex:self.toPageIndex];
            // 视图完成切换
            [self viewDidChange:self.currentPageIndex fromeIndex:self.toPageIndex];
            [self addNeighbourViewControllerWithIndex:self.currentPageIndex];
            
            self.toPageIndex = self.currentPageIndex;
        } else {
            self.currentPageIndex = self.toPageIndex;
        }
        
        // 视图将要切换
        [self addChildViewControllerWithIndex:newToPage];
        [self viewWillChange:newToPage fromeIndex:self.toPageIndex];
        
        self.toPageIndex = newToPage;
    }
}

/// 手指拖动 即将开始
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //    NSLog(@"手指拖动 即将开始  ==================== new start");
}

/// 手指拖动 结束时
/// decelerate为YES时列表会惯性滑动， 为NO时列表直接静止
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != self.pageScrollView) {
        return;
    }
    
    if (!decelerate) {
        //        NSLog(@"手指拖动 结束时 页面直接停止");
        [self scrollViewDidEnd:scrollView];
    } else {
        //        NSLog(@"手指拖动 结束时 页面继续减速滑动");
    }
}

/// 自动滚动结束时,即调用setContentOffset/scrollRectVisible:animated:等函数并且animated为YES时引发的滑动
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    //    NSLog(@"方法调用引起的滑动 结束");
    if (scrollView != self.pageScrollView) {
        return;
    }
    [self scrollViewDidEnd:scrollView];
}

/// 手指拖动引起的滚动开始时
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    //    NSLog(@"手指拖动 离开时 滑动开始减速 isDecelerating: %@", @(scrollView.isDecelerating));
}

/// 手指拖动引起的滚动结束时
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //    NSLog(@"手指拖动 离开后 引起的滑动结束 isDecelerating: %@", @(scrollView.isDecelerating));
    if (scrollView != self.pageScrollView) {
        return;
    }
    [self scrollViewDidEnd:scrollView];
}

/// 列表最终滚动结束时
- (void)scrollViewDidEnd:(UIScrollView *)scrollView {
    if (scrollView != self.pageScrollView) {
        return;
    }
    
    NSLog(@"scroll end ====================");
    
    if (self.currentPageIndex != self.toPageIndex && self.toPageIndex >= 0) {
        // 视图完成切换
        [self viewDidChange:self.toPageIndex fromeIndex:self.currentPageIndex];
        [self addNeighbourViewControllerWithIndex:self.toPageIndex];
        
        // 移除多余视图
        [self removeNotNeighbourViewController];
        
        self.currentPageIndex = self.toPageIndex;
    }
    
    self.toPageIndex = -1;
}

#pragma mark -
#pragma mark - 主容器列表与子页面列表上下联动逻辑处理

/// 子页面完成切换时，记录子页面列表和主容器列表内容偏移相关信息
/// @param toIndex 显示子页面对应的索引
- (void)childViewDidChangedToIndex:(NSInteger)toIndex {
    // 记录当前要展示的子页面的列表及列表当前的内容偏移位置
    self.childScrollView = [self viewControllerAtIndex:toIndex].childScrollView;
    self.childScrollViewOffset = self.childScrollView.contentOffset;
    
    // 页面切换时记录主列表容器内容偏移位置
    self.baseScrollViewOffset = self.baseScrollView.contentOffset;
    self.baseScrollViewVelocity = CGPointZero;
}

/// 最底层的滚动列表滚动，计算移动位置
- (void)baseScrollViewDidScroll {
    
    // 没有headerView时，baseScrollView不应该设置下拉刷新，也不允许滑动
    if (![self haveHeaderView]) {
        self.baseScrollView.contentOffset = CGPointZero;
        return;
    }
    
    // 通过手势滑动速率实时判断手势当前的滑动方向
    CGPoint velocity = [self.baseScrollView.panGestureRecognizer velocityInView:self.baseScrollView];
    
    if (velocity.y > 0 || (velocity.y == 0 && self.baseScrollViewOffset.y > 0)) {
        // 当前手势向下滑，如果子列表内容没有滑到其顶部，则先让其下滑，主容器内容位置偏移保持不变
        if (self.childScrollView && self.childScrollView.contentOffset.y > 0) {
            self.baseScrollView.contentOffset = self.baseScrollViewOffset;
        }
    } else if (velocity.y < 0 || (velocity.y == 0 && self.baseScrollViewOffset.y < 0)) {
        // 当前手势向上滑, 主容器到达悬浮位置，主容器内容位置偏移保持不变
        if ([self haveHeaderView] && self.baseScrollView.contentOffset.y >= [self headerStopPoint].y) {
            self.baseScrollView.contentOffset = [self headerStopPoint];
        }
    }
    self.baseScrollViewOffset = self.baseScrollView.contentOffset;
    
    if (velocity.y != 0) {
        self.baseScrollViewVelocity = velocity;
    }
    
    !self.baseScrollViewDidScrolling ?: self.baseScrollViewDidScrolling(self.baseScrollView);
}

/// 接收子页面控制器中滚动列表视图的滚动信息
/// 当设置了headerView或subHeaderView后，子视图滚动需调此方法将子列表传入进行位置移动计算
/// @param scrollView 子页面滚动列表
- (void)childScrollViewDidScroll:(UIScrollView *)scrollView {
    // 没有headerView时，不限制子页面列表的滚动
    if (![self haveHeaderView]) {
        return;
    }
    
    self.childScrollView = scrollView;
    
    // 通过手势滑动速率实时判断手势当前的滑动方向
    CGPoint velocity = [self.childScrollView.panGestureRecognizer velocityInView:self.childScrollView];
    
    if (velocity.y >= 0) {
        // 当前手势向下滑，子列表内容下滑不能超过其顶部
        if (self.childScrollView.contentOffset.y <= 0) {
            self.childScrollView.contentOffset = CGPointZero;
        }
    } else if (velocity.y < 0) {
        // 当前手势向上滑，主容器未到达悬浮位置，子列表内容位置偏移保持不变
        if ([self haveHeaderView] && self.baseScrollView.contentOffset.y < [self headerStopPoint].y) {
            if (self.childScrollViewOffset.y <= 0) {
                self.childScrollView.contentOffset = CGPointMake(self.childScrollView.contentOffset.x, 0);
            } else {
                self.childScrollView.contentOffset = self.childScrollViewOffset;
            }
        }
    }
    
    self.childScrollViewOffset = CGPointMake(self.childScrollView.contentOffset.x, MAX(0, self.childScrollView.contentOffset.y));
}

/// 计算header悬停的位置
- (CGPoint)headerStopPoint {
    if (self.subHeaderView) {
        return CGPointMake(0, self.subHeaderView.frame.origin.y);
    } else if (self.headerView) {
        return CGPointMake(0, self.headerView.frame.size.height);
    }
    return CGPointZero;
}

/// 是否有头视图
- (BOOL)haveHeaderView {
    return self.headerView || self.subHeaderView;
}

@end

