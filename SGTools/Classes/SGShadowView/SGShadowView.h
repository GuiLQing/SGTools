//
//  SGShadowView.h
//  SGShadowView
//
//  Created by Sunshine on 2019/1/29.
//  Copyright © 2019 com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, SGShadowSide) {
    SGShadowSideTop       = 1 << 0,
    SGShadowSideBottom    = 1 << 1,
    SGShadowSideLeft      = 1 << 2,
    SGShadowSideRight     = 1 << 3,
    SGShadowSideAllSides  = ~0UL
};

@interface SGShadowView : UIView

/**
 * 设置四周阴影: shaodwRadius:5  shadowColor:[UIColor colorWithWhite:0 alpha:0.3]
 */
- (void)sg_shaodw;
/**
 * 设置垂直方向的阴影
 *
 * @param shadowRadius   阴影半径
 * @param shadowColor    阴影颜色
 * @param shadowOffset   阴影b偏移
 */
- (void)sg_verticalShaodwRadius:(CGFloat)shadowRadius
                    shadowColor:(UIColor *)shadowColor
                   shadowOffset:(CGSize)shadowOffset;
/**
 * 设置水平方向的阴影
 *
 * @param shadowRadius   阴影半径
 * @param shadowColor    阴影颜色
 * @param shadowOffset   阴影b偏移
 */
- (void)sg_horizontalShaodwRadius:(CGFloat)shadowRadius
                      shadowColor:(UIColor *)shadowColor
                     shadowOffset:(CGSize)shadowOffset;
/**
 * 设置阴影
 *
 * @param shadowRadius   阴影半径
 * @param shadowColor    阴影颜色
 * @param shadowOffset   阴影b偏移
 * @param shadowSide     阴影边
 */
- (void)sg_shaodwRadius:(CGFloat)shadowRadius
            shadowColor:(UIColor *)shadowColor
           shadowOffset:(CGSize)shadowOffset
           byShadowSide:(SGShadowSide)shadowSide;

/**
 * 设置圆角（四周）
 *
 * @param cornerRadius   圆角半径
 */
- (void)sg_cornerRadius:(CGFloat)cornerRadius;
/**
 * 设置圆角
 *
 * @param cornerRadius   圆角半径
 * @param corners        圆角边
 */
- (void)sg_cornerRadius:(CGFloat)cornerRadius
      byRoundingCorners:(UIRectCorner)corners;

@end
