//
//  MDTabView.h
//  MDPageViewController
//
//  Created by hq on 2022/2/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDTabView : UIView

@property (nonatomic, copy) void (^clickIndexBlock)(NSInteger index);

/// tab总数
@property (nonatomic, assign) NSInteger count;

- (void)showAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
