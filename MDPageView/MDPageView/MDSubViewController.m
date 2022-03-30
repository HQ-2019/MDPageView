//
//  MDSubViewController.m
//  MDPageView
//
//  Created by hq on 2022/2/17.
//

#import "MDSubViewController.h"
#import "UIViewController+MDPageView.h"

@interface MDSubViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MDSubViewController

- (void)dealloc {
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), self.content);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.color;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initSubView];
    });
    NSLog(@"%@ %@",  NSStringFromSelector(_cmd), self.content);
}

- (void)initSubView {
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(100, 200, 100, 50);
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = UIColor.purpleColor;
    label.text = self.content;
    [self.view addSubview:label];
    
    if (self.showListView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.frame = self.view.bounds;
        tableView.backgroundColor = UIColor.grayColor;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.view addSubview:tableView];
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        tableView.tableHeaderView = label;
        self.childScrollView = tableView;
        self.tableView = tableView;
    }
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

/// 下拉刷新
/// @param complete 完成后回填
- (void)pullDownRefresh:(void(^)(void))complete {
    // 模拟下拉处理过程，2秒后回调
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        !complete ?: complete();
    });
}

#pragma mark -
#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arc4random() % 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"列表 - %@", @(indexPath.row)];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.childDidScroll ?: self.childDidScroll(scrollView);
}

@end
