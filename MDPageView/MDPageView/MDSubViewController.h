//
//  MDSubViewController.h
//  MDPageView
//
//  Created by hq on 2022/2/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDSubViewController : UIViewController

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) BOOL showListView;

@property (nonatomic, copy) void(^childDidScroll)(UIScrollView *scrollView);


@end

NS_ASSUME_NONNULL_END
