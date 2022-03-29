//
//  MDSubViewController.m
//  MDPageView
//
//  Created by hq on 2022/2/17.
//

#import "MDSubViewController.h"
#import "UIViewController+md.h"

@interface MDSubViewController () <UITableViewDelegate, UITableViewDataSource>

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

#pragma mark -
#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 40;
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
