//
//  ViewController.m
//  MDPageViewController
//
//  Created by hq on 2022/2/17.
//

#import "ViewController.h"
#import "TestUIPageViewController.h"
#import "TestMDPageViewController.h"
#import "MDBaseNavigationController.h"

@interface ViewController () <UIGestureRecognizerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    // 系统UIPageViewController
    [self initButton:@"Test-UIPage" frame:CGRectMake((self.view.frame.size.width - 150.0) / 2.0, 150, 150, 70) sel:@selector(pushUIPageViewController)];
    
    // 自定义MDPageViewController
    [self initButton:@"Test-MDPage" frame:CGRectMake((self.view.frame.size.width - 150.0) / 2.0, 250, 150, 70) sel:@selector(pushMDPageViewController)];
    
    [self initButton:@"测试全屏返回" frame:CGRectMake((self.view.frame.size.width - 150.0) / 2.0, 350, 150, 70) sel:@selector(xxxxxxx)];
}

- (void)initButton:(NSString *)title frame:(CGRect)frame sel:(SEL)sel {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    button.backgroundColor = UIColor.grayColor;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)pushUIPageViewController {
    TestUIPageViewController *controller = [TestUIPageViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushMDPageViewController {
    TestMDPageViewController *controller = [TestMDPageViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)xxxxxxx {
    ViewController *controller = [ViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), NSStringFromClass([self class]));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), NSStringFromClass([self class]));
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
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
