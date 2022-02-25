//
//  ViewController.m
//  MDPageView
//
//  Created by hq on 2022/2/17.
//

#import "ViewController.h"
#import "TestUIPageViewController.h"
#import "TestMDPageViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // 系统UIPageViewController
    [self initButton:@"Test-UIPage" frame:CGRectMake((self.view.frame.size.width - 150.0) / 2.0, 150, 150, 70) sel:@selector(pushUIPageViewController)];
    
    // 自定义MDPageViewController
    [self initButton:@"Test-MDPage" frame:CGRectMake((self.view.frame.size.width - 150.0) / 2.0, 250, 150, 70) sel:@selector(pushMDPageViewController)];
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

@end
