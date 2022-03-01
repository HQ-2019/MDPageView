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

@end

@implementation TestMDPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"MDPageViewController";
    
    __weak typeof(self) weakSelf = self;
    NSInteger showIndex = 1;
    
    
    MDPageViewController *controller = [MDPageViewController new];
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
    [controller updateViewControllers:self.viewControllers];
    [controller showPageAtIndex:showIndex animated:NO];
    
    controller.viewScrollCallBack = ^(CGPoint contentOffset, CGSize contentSize, BOOL isDragging) {
        //        NSLog(@"Offset: %@    isDragging: %@", @(contentOffset.x), @(isDragging));
    };
    controller.viewWillChangedCallBack = ^(NSInteger toIndex, NSInteger fromIndex) {
        //        NSLog(@"----------------------------------   页面将要切换  %@ -> %@", @(fromIndex), @(toIndex));
        [weakSelf.tabView showAtIndex:toIndex];
    };
    controller.viewDidChangedCallBack = ^(NSInteger toIndex, NSInteger fromIndex) {
        NSLog(@"==================================   页面切换完成  %@ -> %@", @(fromIndex), @(toIndex));
        [weakSelf.tabView showAtIndex:toIndex];
    };
    
    
    // 模拟重置
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"重置 ################################");
        NSArray *colors = @[ UIColor.grayColor, UIColor.orangeColor, UIColor.purpleColor, UIColor.redColor, UIColor.blueColor,UIColor.yellowColor, UIColor.purpleColor];
        NSMutableArray *vcList = @[].mutableCopy;
        [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MDSubViewController *controller = [MDSubViewController new];
            controller.content = [NSString stringWithFormat:@"页面： %@", @(idx)];
            controller.color = obj;
            [vcList addObject:controller];
        }];
        self.viewControllers = vcList;
        [controller updateViewControllers:vcList];
        [controller showPageAtIndex:2 animated:NO];
        
        self.tabView.count = self.viewControllers.count;
    });
    
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
        [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MDSubViewController *controller = [MDSubViewController new];
            controller.content = [NSString stringWithFormat:@"页面： %@", @(idx)];
            controller.color = obj;
            [vcList addObject:controller];
        }];
        
        _viewControllers = [NSArray arrayWithArray:vcList];
    }
    return _viewControllers;
}

@end
