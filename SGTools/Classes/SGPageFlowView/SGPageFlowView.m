//
//  SGPageFlowView.m
//  SGPagedFlowView
//
//  Created by lg on 2019/5/8.
//  Copyright © 2019 lg. All rights reserved.
//

#import "SGPageFlowView.h"

@interface SGPageFlowView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *cachedCells;
@property (nonatomic, strong) NSMutableSet *reusableCells;

@property (nonatomic, assign) NSRange visibleRange;
@property (nonatomic, assign) NSInteger Page;

@end

@implementation SGPageFlowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _left_Right_Margin = 20.0f;
        _top_Bottom_Margin = 20.0f;
        
        CGFloat pageWidth = self.bounds.size.width - 2 * _left_Right_Margin;
        _sizeOfPage = CGSizeMake(pageWidth, self.bounds.size.height);
        
        [self layoutScrollView];
    }
    return self;
}

- (void)layoutScrollView {
    _scrollView = UIScrollView.alloc.init;
    _scrollView.frame = CGRectMake(0, 0, self.sizeOfPage.width, self.sizeOfPage.height);
    _scrollView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.clipsToBounds = NO;
    [self addSubview:_scrollView];
}

- (void)sg_reloadData {
    /** 将所有缓存的cell从父视图中移出，并清空缓存 */
    [self refreshCachedCells];
    [self.reusableCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.reusableCells removeAllObjects];
    
    /** 配置滚动视图 */
    [self configScrollView];
    /** 配置数据缓存 */
    [self configPagesDataSource];
    /** 刷新可见cell */
    [self refreshVisibleCell];
}

- (void)sg_reloadDataAndOffsetToIndex:(NSInteger)index {
    [self sg_reloadData];
    [self.scrollView setContentOffset:CGPointMake(_sizeOfPage.width * (self.numberOfPages + index), 0) animated:NO];
    [self scrollViewWillEndDragging:self.scrollView withVelocity:CGPointZero targetContentOffset:nil];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)configScrollView {
    self.scrollView.frame = CGRectMake(0, 0, _sizeOfPage.width, _sizeOfPage.height);
    self.scrollView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    /** 设置scrollView的内容大小有3部分的大小，每部分都包含所有的界面 */
    self.scrollView.contentSize = CGSizeMake(_sizeOfPage.width * (self.numberOfPages == 1 ? 1 : (self.numberOfPages * 3)), 0);
    /** 设置scrollView的偏移亮从第二部分开始 */
    self.scrollView.contentOffset = CGPointMake(_sizeOfPage.width * self.numberOfPages, 0);
    _Page = self.numberOfPages;
}

- (void)configPagesDataSource {
    
    NSInteger startPage = MAX(self.Page - 2, 0);
    NSInteger endPage = MIN(self.Page + 2, self.numberOfPages == 1 ? 1 : self.numberOfPages * 3);
    self.visibleRange = NSMakeRange(startPage, endPage - startPage + 1);
    
    NSMutableArray *availableCells = [self.cachedCells mutableCopy];
    [self refreshCachedCells];
    
    /** 默认缓存中间一个、左右各两个cell */
    for (NSInteger page = startPage; page <= endPage; page ++) {
        UIView *cell = [availableCells objectAtIndex:page];
        if ([cell isEqual:[NSNull null]]) {
            cell = [self.dataSource sg_pageFlowView:self cellForPageAtIndex:page % self.numberOfPages];
        }
        if (cell) {
            [self.cachedCells replaceObjectAtIndex:page withObject:cell];
            [availableCells replaceObjectAtIndex:page withObject:[NSNull null]];
            
            cell.frame = CGRectMake(self.sizeOfPage.width * page, 0, self.sizeOfPage.width, self.sizeOfPage.height);
            if (!cell.superview) {
                [self.scrollView addSubview:cell];
            }        
        }
    }
    
    /** 将没有用上的cell放入缓冲区，下次先从缓冲区获取cell */
    for (UIView *cell in availableCells) {
        if (![cell isEqual:[NSNull null]]) {
            [self.reusableCells addObject:cell];
            [cell removeFromSuperview];
        }
    }
}

- (void)refreshVisibleCell {
    if (self.left_Right_Margin == 0 && self.top_Bottom_Margin == 0) {
        return ;
    }
    
    CGFloat offset = _scrollView.contentOffset.x;

    for (NSInteger page = self.visibleRange.location; page < self.visibleRange.location + _visibleRange.length; page++) {
        UIView *cell = [self sg_cellForPageAtIndex:page];
        if ([cell isEqual:[NSNull null]]) continue;
        
        CGFloat origin = cell.frame.origin.x;
        CGFloat delta = fabs(origin - offset);

        CGRect originCellFrame = CGRectMake(self.sizeOfPage.width * page, 0, self.sizeOfPage.width, self.sizeOfPage.height);//如果没有缩小效果的情况下的本该的Frame

        if (delta < self.sizeOfPage.width) {

            CGFloat leftRightInset = self.left_Right_Margin * delta / self.sizeOfPage.width;
            CGFloat topBottomInset = self.top_Bottom_Margin * delta / self.sizeOfPage.width;

            cell.layer.transform = CATransform3DMakeScale((self.sizeOfPage.width-leftRightInset * 2)/self.sizeOfPage.width,(self.sizeOfPage.height-topBottomInset * 2)/self.sizeOfPage.height, 1.0);
            cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset));
        } else {
            cell.layer.transform = CATransform3DMakeScale((self.sizeOfPage.width-self.left_Right_Margin*2) / self.sizeOfPage.width,(self.sizeOfPage.height-self.top_Bottom_Margin*2)/self.sizeOfPage.height, 1.0);
            cell.frame = UIEdgeInsetsInsetRect(originCellFrame, UIEdgeInsetsMake(self.top_Bottom_Margin, self.left_Right_Margin, self.top_Bottom_Margin, self.left_Right_Margin));
        }
    }
}

- (NSInteger)numberOfPages {
    return [self.dataSource sg_numberOfPagesInFlowView:self];
}

- (UIView *)sg_dequeueReusableCell {
    for (UIView *cell in self.reusableCells) {
        UIView *strongCell = cell;
        [self.reusableCells removeObject:cell];
        return strongCell;
    }
    return nil;
}

- (id)sg_cellForPageAtIndex:(NSInteger)index {
    return [self.cachedCells objectAtIndex:index];
}

- (void)refreshCachedCells {
    for (id cell in self.cachedCells) {
        if ([cell isKindOfClass:[UIView class]]) {
            [cell removeFromSuperview];
        }
    }
    self.cachedCells = [NSMutableArray array];
    for (NSInteger i = 0; i < self.numberOfPages * 3; i ++) {
        [self.cachedCells addObject:[NSNull null]];
    }
}

- (NSMutableSet *)reusableCells {
    if (!_reusableCells) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger pageIndex = (int)round(scrollView.contentOffset.x / self.sizeOfPage.width) % self.numberOfPages;
    
    if (scrollView.contentOffset.x / self.sizeOfPage.width >= 2 * self.numberOfPages) {
        [scrollView setContentOffset:CGPointMake(self.sizeOfPage.width * self.numberOfPages, 0) animated:NO];
        _Page = self.numberOfPages;
    }
    if (scrollView.contentOffset.x / self.sizeOfPage.width <= self.numberOfPages - 1) {
        [scrollView setContentOffset:CGPointMake((2 * self.numberOfPages - 1) * self.sizeOfPage.width, 0) animated:NO];
        _Page = 2 * self.numberOfPages;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sg_pageFlowViw:didScrollToPage:)] && _currentPage != pageIndex && pageIndex >= 0) {
        [self.delegate sg_pageFlowViw:self didScrollToPage:pageIndex];
    }
    _currentPage = pageIndex;
    
    /** 配置数据缓存 */
    [self configPagesDataSource];
    /** 刷新可见cell */
    [self refreshVisibleCell];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (_Page == floor((scrollView.contentOffset.x + self.sizeOfPage.width / 2) / self.sizeOfPage.width)) {
        _Page = floor(scrollView.contentOffset.x /  self.sizeOfPage.width) + 1;
    }else {
        _Page = floor(scrollView.contentOffset.x /  self.sizeOfPage.width);
    }
}

@end
