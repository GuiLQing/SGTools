//
//  UIView+SGGradient.m
//  AFNetworking
//
//  Created by lancoo on 2020/3/31.
//

#import "UIView+SGGradient.h"
#import <objc/runtime.h>

@implementation UIView (SGGradient)

+ (Class)layerClass {
    return [CAGradientLayer class];
}

+ (UIView *)sg_gradientViewWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    UIView *view = [[self alloc] init];
    [view sg_setGradientBackgroundWithColors:colors locations:locations startPoint:startPoint endPoint:endPoint];
    return view;
}

- (void)sg_setGradientBackgroundWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    NSMutableArray *colorsM = [NSMutableArray array];
    for (UIColor *color in colors) {
        [colorsM addObject:(__bridge id)color.CGColor];
    }
    self.sg_colors = [colorsM copy];
    self.sg_locations = locations;
    self.sg_startPoint = startPoint;
    self.sg_endPoint = endPoint;
}

#pragma mark- Getter&Setter

- (NSArray *)sg_colors {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSg_colors:(NSArray *)colors {
    objc_setAssociatedObject(self, @selector(sg_colors), colors, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setColors:self.sg_colors];
    }
}

- (NSArray<NSNumber *> *)sg_locations {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSg_locations:(NSArray<NSNumber *> *)locations {
    objc_setAssociatedObject(self, @selector(sg_locations), locations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setLocations:self.sg_locations];
    }
}

- (CGPoint)sg_startPoint {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

- (void)setSg_startPoint:(CGPoint)startPoint {
    objc_setAssociatedObject(self, @selector(sg_startPoint), [NSValue valueWithCGPoint:startPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setStartPoint:self.sg_startPoint];
    }
}

- (CGPoint)sg_endPoint {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

- (void)setSg_endPoint:(CGPoint)endPoint {
    objc_setAssociatedObject(self, @selector(toDistance), [NSValue valueWithCGPoint:endPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.layer isKindOfClass:[CAGradientLayer class]]) {
        [((CAGradientLayer *)self.layer) setEndPoint:self.sg_endPoint];
    }
}

@end


@implementation UILabel (Gradient)

+ (Class)layerClass {
    return [CAGradientLayer class];
}

@end
