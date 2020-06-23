//
//  SGPageFlowView.h
//  SGPagedFlowView
//
//  Created by lg on 2019/5/8.
//  Copyright © 2019 lg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SGPageFlowViewDataSource, SGPageFlowViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SGPageFlowView : UIView

@property (nonatomic, weak) id <SGPageFlowViewDataSource> dataSource;
@property (nonatomic, weak) id <SGPageFlowViewDelegate> delegate;

@property (nonatomic, assign) CGFloat left_Right_Margin;
@property (nonatomic, assign) CGFloat top_Bottom_Margin;
@property (nonatomic, assign) CGSize sizeOfPage;
@property (nonatomic, assign, readonly) NSInteger currentPage;

- (void)sg_reloadDataAndOffsetToIndex:(NSInteger)index;
- (void)sg_reloadData;
- (id)sg_dequeueReusableCell;
- (id)sg_cellForPageAtIndex:(NSInteger)index;

@end

@protocol SGPageFlowViewDataSource <NSObject>

- (NSInteger)sg_numberOfPagesInFlowView:(SGPageFlowView *)flowView;
- (id)sg_pageFlowView:(SGPageFlowView *)pageFlowView cellForPageAtIndex:(NSInteger)index;

@end

@protocol SGPageFlowViewDelegate <UIScrollViewDelegate>

@optional

- (void)sg_pageFlowViw:(SGPageFlowView *)pageFlowView didScrollToPage:(NSInteger)pageNumber;

@end

NS_ASSUME_NONNULL_END
