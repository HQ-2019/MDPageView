//
//  MDSubViewController.m
//  MDPageView
//
//  Created by hq on 2022/2/17.
//

#import "MDSubViewController.h"

@interface MDSubViewController ()

@end

@implementation MDSubViewController

- (void)dealloc {
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), self.content);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.color;
    [self initSubView];
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), self.content);
}

- (void)initSubView {
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(100, 200, 100, 50);
    label.text = self.content;
    [self.view addSubview:label];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
//    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), self.content);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), self.content);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), self.content);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), self.content);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), self.content);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), self.content);
}

@end
