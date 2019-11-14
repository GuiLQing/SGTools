//
//  UIView+SGShadow.h
//  ShadowPathAnimationDemo
//
//  Created by SG on 2019/11/11.
//  Copyright © 2019 Rain Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SGShadowOptions) {
    SGShadowOptionsNone      = 0,
    SGShadowOptionsTop       = 1 << 0,
    SGShadowOptionsLeft      = 1 << 1,
    SGShadowOptionsBottom    = 1 << 2,
    SGShadowOptionsRight     = 1 << 3,
    SGShadowOptionsAll       = ~0UL
};

@interface SGShadowConfig : NSObject

@property (nonatomic, assign) SGShadowOptions shadowOptions;

@property (nonatomic, strong) UIColor *shadowColor;

@property (nonatomic, assign) CGFloat shadowOpacity;

@property (nonatomic, assign) CGSize shadowOffset;

@property (nonatomic, assign) CGFloat shadowRadius;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, assign) CGFloat borderWidth;

@end

@interface UIView (SGShadow)

- (void (^)(SGShadowConfig * _Nonnull shadowConfig))sg_shadowConfig;

- (void (^)(void (^ _Nullable)(SGShadowConfig * _Nonnull config)))sg_updateShadowOptionsConfig;

@end

static inline SGShadowConfig * SGShadowConfigMake(SGShadowOptions shadowOptions, UIColor * _Nullable shadowColor, CGFloat shadowOpacity, CGSize shadowOffset, CGFloat shadowRadius, CGFloat cornerRadius, UIColor * _Nullable borderColor, CGFloat borderWidth) {
    SGShadowConfig *config = [[SGShadowConfig alloc] init];
    config.shadowOptions = shadowOptions;
    config.shadowColor = shadowColor;
    config.shadowOpacity = shadowOpacity;
    config.shadowOffset = shadowOffset;
    config.shadowRadius = shadowRadius;
    config.cornerRadius = cornerRadius;
    config.borderColor = borderColor;
    config.borderWidth = borderWidth;
    return config;
}

static inline SGShadowConfig * SGShadowConfigLancooNormal(UIColor * _Nullable shadowColor, CGFloat cornerRadius, UIColor * _Nullable borderColor, CGFloat borderWidth) {
    return SGShadowConfigMake(SGShadowOptionsBottom, shadowColor, 0.8f, CGSizeMake(0, 3.0f), 5.0f, cornerRadius, borderColor, borderWidth);
}

NS_ASSUME_NONNULL_END
