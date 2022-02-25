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
    
    MDTabView *tabView = [[MDTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    
    MDPageViewController *controller = [MDPageViewController new];
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    [controller setViewControllers:self.viewControllers index:showIndex];
    controller.viewScrollCallBack = ^(CGPoint contentOffset, CGSize contentSize, BOOL isDragging) {
        //        NSLog(@"Offset: %@    isDragging: %@", @(contentOffset.x), @(isDragging));
    };
    controller.viewDidChangedCallBack = ^(NSInteger toIndex, NSInteger fromIndex) {
        NSLog(@"xxxxxxxxxxxxxxx   页面切换完成  %@ -> %@", @(fromIndex), @(toIndex));
        [weakSelf.tabView showAtIndex:toIndex];
    };
    
    
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

@end
