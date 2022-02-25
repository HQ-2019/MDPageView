//
//  MDTabView.m
//  MDPageView
//
//  Created by hq on 2022/2/22.
//

#import "MDTabView.h"

@interface MDTabView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *sliderView;

@end

@implementation MDTabView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.itemSize = CGSizeMake(frame.size.height, frame.size.height);
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        self.collectionView.backgroundColor = UIColor.grayColor;
        
        self.sliderView = [UIView new];
        self.sliderView.backgroundColor = UIColor.redColor;
        self.sliderView.frame = CGRectMake(0, frame.size.height - 4, frame.size.height, 4);
        [self addSubview:self.sliderView];
        
    }
    return self;
}

- (void)setCount:(NSInteger)count {
    _count = count;
    [self.collectionView reloadData];
}

- (void)showAtIndex:(NSInteger)index {
    
    [self.collectionView layoutIfNeeded];
    [self.collectionView layoutSubviews];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    [self.sliderView.layer removeAllAnimations];
    [UIView animateWithDuration:0.3 animations:^{
        self.sliderView.frame = CGRectMake(cell.frame.origin.x, cell.frame.size.height - 4, cell.frame.size.height, 4);
    }];
}


#pragma mark -
#pragma mark - UICollectionViewDataSource / UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                                       forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"%@", @(indexPath.row)];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = cell.bounds;
    [cell.contentView addSubview:label];
    
    UIView *v = [[UIView alloc] initWithFrame:cell.bounds];
    v.backgroundColor = UIColor.orangeColor;
    cell.selectedBackgroundView = v;
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    !self.clickIndexBlock ?: self.clickIndexBlock(indexPath.row);
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    [self.sliderView.layer removeAllAnimations];
    [UIView animateWithDuration:0.3 animations:^{
        self.sliderView.frame = CGRectMake(cell.frame.origin.x, cell.frame.size.height - 4, cell.frame.size.height, 4);
    }];
}

@end
