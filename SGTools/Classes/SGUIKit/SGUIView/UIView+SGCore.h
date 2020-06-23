//
//  UIView+SGCore.h
//  Pods-SGCore_Example
//
//  Created by SG on 2020/1/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SGCore)

/** 尺寸 */
@property (nonatomic, assign) CGSize sg_size;
/** 原点坐标 */
@property (nonatomic, assign) CGPoint sg_origin;
/** x 坐标 */
@property (nonatomic, assign) CGFloat sg_x;
/** y 坐标 */
@property (nonatomic, assign) CGFloat sg_y;
/** 宽度 */
@property (nonatomic, assign) CGFloat sg_width;
/** 高度 */
@property (nonatomic, assign) CGFloat sg_height;
/** 中心点 x 坐标 */
@property (nonatomic, assign) CGFloat sg_centerX;
/** 中心点 y 坐标 */
@property (nonatomic, assign) CGFloat sg_centerY;
/** 顶部坐标 */
@property (nonatomic, assign) CGFloat sg_top;
/** 左边坐标 */
@property (nonatomic, assign) CGFloat sg_left;
/** 右边坐标 */
@property (nonatomic, assign) CGFloat sg_right;
/** 底部坐标 */
@property (nonatomic, assign) CGFloat sg_bottom;

#pragma mark - Set AnchorPoint

- (void)sg_setPosition:(CGPoint)point anchorPoint:(CGPoint)anchorPoint;

@end

@interface UIView (SGClipsBounds)

/** 切任意圆角 */
@property (nonatomic, copy, readonly) UIView * (^sg_clipsToBounds)(UIRectCorner corners, CGFloat cornerRadius);

@end

@interface UIView (SGAccessoryView)

- (UIToolbar *)sg_customAccessoryView;

@end

NS_ASSUME_NONNULL_END
