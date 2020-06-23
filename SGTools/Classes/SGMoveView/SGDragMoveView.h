//
//  SGDragMoveView.h
//  SGDragTestDemo
//
//  Created by lancoo on 2020/5/14.
//  Copyright © 2020 lancoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SGDragMoveView;

NS_ASSUME_NONNULL_BEGIN

@protocol SGDragMoveViewDataSource <NSObject>

@required
/// 获取需要加载的控件数量
- (NSInteger)numberOfItemsInDragMoveView:(SGDragMoveView *)dragMoveView;
/// 获取当前下标的控件
- (UIView *)dragMoveView:(SGDragMoveView *)dragMoveView viewForItemAtIndex:(NSInteger)index;

@end

@protocol SGDragMoveViewDelegate <NSObject>

@optional
/// 移动完成回调
- (void)dragMoveView:(SGDragMoveView *)dragMoveView moveItemFromIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;

@end

@interface SGDragMoveView : UIView

@property (nonatomic, weak) id<SGDragMoveViewDataSource> dataSource;
@property (nonatomic, weak) id<SGDragMoveViewDelegate> delegate;
/// 内容上左下右边距  默认:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)
@property (nonatomic, assign) UIEdgeInsets contentInset;
/// 最小行间距  默认:10.0f
@property (nonatomic, assign) CGFloat minimumLineSpacing;
/// 最小控件间距  默认:10.0f
@property (nonatomic, assign) CGFloat minimumItemSpacing;
/// 长按多少秒触发拖动手势，默认0.1秒，如果设置为0，表示手指按下去立刻就触发拖动
@property (nonatomic, assign) NSTimeInterval minimumPressDuration;
/// 禁止移动，默认NO
@property (nonatomic, assign) BOOL isMoveDisabled;
/// 是否禁止拖动到边缘滚动的功能，默认NO
@property (nonatomic, assign) BOOL isEdgeScrollDisabled;
/// 是否开启拖动的时候所有item抖动的效果，默认NO
@property (nonatomic, assign) BOOL isShakeWhenMoveing;
/// 抖动的等级(1.0f~10.0f)，默认4
@property (nonatomic, assign) CGFloat shakeLevel;

/// 刷新数据源
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
