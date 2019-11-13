//
//  UIView+SGShadow.m
//  ShadowPathAnimationDemo
//
//  Created by SG on 2019/11/11.
//  Copyright © 2019 Rain Wang. All rights reserved.
//

#import "UIView+SGShadow.h"
#import <objc/runtime.h>

static inline void SGShadowSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    // 若已经存在，则添加会失败
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    // 若原来的方法并不存在，则添加即可
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation SGShadowConfig

@end

static inline void SGShadowLayerUpdate(CALayer *layer, SGShadowConfig *config) {
    layer.shadowColor = config.shadowColor.CGColor;
    layer.shadowOpacity = config.shadowOpacity;
    layer.shadowOffset = config.shadowOffset;
    layer.shadowRadius = config.shadowRadius;
    
    layer.cornerRadius = config.cornerRadius;
    layer.borderColor = config.borderColor.CGColor;
    layer.borderWidth = config.borderWidth;
    layer.masksToBounds = NO;
}

@interface UIView ()

@property (nonatomic, strong) SGShadowConfig *shadowConfig;

@end

@implementation UIView (SGShadow)

+ (void)load {
    SGShadowSwizzleSelector(self.class, @selector(layoutSubviews), @selector(sg_shadow_layoutSubviews));
}

- (void)sg_shadow_layoutSubviews {
    [self sg_shadow_layoutSubviews];
    
    if (self.shadowConfig.shadowOptions != SGShadowOptionsNone) {
        [self sg_updateShadow];
    }
}

- (void)sg_updateShadow {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    SGShadowLayerUpdate(self.layer, self.shadowConfig);
    
    SGShadowOptions shadowOptions = self.shadowConfig.shadowOptions;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [path moveToPoint:center];
    
    if (shadowOptions & SGShadowOptionsTop) {
        [path addLineToPoint:CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds))];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds))];
        [path addLineToPoint:center];
    }
    if (shadowOptions & SGShadowOptionsLeft) {
        [path addLineToPoint:CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds))];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds))];
        [path addLineToPoint:center];
    }
    if (shadowOptions & SGShadowOptionsBottom) {
        [path addLineToPoint:CGPointMake(CGRectGetMinX(self.bounds) + self.shadowConfig.cornerRadius / 2, CGRectGetMaxY(self.bounds))];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds) - self.shadowConfig.cornerRadius / 2, CGRectGetMaxY(self.bounds))];
        [path addLineToPoint:center];
    }
    if (shadowOptions & SGShadowOptionsRight) {
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds))];
        [path addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds))];
        [path addLineToPoint:center];
    }
    self.layer.shadowPath = path.CGPath;
}

- (void (^)(SGShadowConfig * _Nonnull))sg_shadowConfig {
    return ^(SGShadowConfig * _Nonnull shadowConfig) {
        if (shadowConfig != nil && ![shadowConfig isKindOfClass:NSNull.class] && ![shadowConfig isEqual:NSNull.null]) {
            self.shadowConfig = shadowConfig;
        }
    };
}

- (void (^)(void (^ _Nullable)(SGShadowConfig * _Nonnull)))sg_updateShadowOptionsConfig {
    return ^(void (^ _Nullable sg_updateShadowOptionsConfig)(SGShadowConfig * _Nonnull configs)) {
        if (sg_updateShadowOptionsConfig) sg_updateShadowOptionsConfig(self.shadowConfig);
    };
}

#pragma mark - property

- (void)setShadowConfig:(SGShadowConfig *)shadowConfig {
    objc_setAssociatedObject(self, @selector(shadowConfig), shadowConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SGShadowConfig *)shadowConfig {
    SGShadowConfig *shadowConfig = objc_getAssociatedObject(self, @selector(shadowConfig));
    if (shadowConfig == nil) {
        shadowConfig = [[SGShadowConfig alloc] init];
        objc_setAssociatedObject(self, @selector(shadowConfig), shadowConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return shadowConfig;
}

@end

@implementation UIButton (SGShadow)

+ (void)load {
    SGShadowSwizzleSelector(self.class, @selector(layoutSubviews), @selector(sg_button_shadow_layoutSubviews));
}

- (void)sg_button_shadow_layoutSubviews {
    [self sg_button_shadow_layoutSubviews];
    
    if (self.shadowConfig.shadowOptions != SGShadowOptionsNone) {
        [self sg_updateShadow];
    }
}

@end
