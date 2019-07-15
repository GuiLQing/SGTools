//
//  SGTriagleView.h
//  TimeTest
//
//  Created by zzc-13 on 2018/4/13.
//  Copyright © 2018年 lzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SGTriangleViewStyle) {
    SGTriangleViewIsoscelesTop,
    SGTriangleViewIsoscelesLeft,
    SGTriangleViewIsoscelesBottom,
    SGTriangleViewIsoscelesRight,
};

@interface SGTriangleView : UIView


/**
 @param color 填充颜色
 @param style 三角形样式
 @return TriangleView
 */
- (instancetype)sg_initWithColor:(UIColor *)color style:(SGTriangleViewStyle)style;

/**
 @param color 填充颜色,
     style default:triangleViewIsoscelesTop
 @return TriangleView
 */
- (instancetype)sg_initWithColor:(UIColor *)color;

- (void)sg_triangleView_setColor:(UIColor *)color style:(SGTriangleViewStyle)style;
- (void)sg_triangleView_setStyle:(SGTriangleViewStyle)style;
- (void)sg_triangleView_setColor:(UIColor *)color;

@end
