//
//  UIView+SGCore.m
//  Pods-SGCore_Example
//
//  Created by SG on 2020/1/13.
//

#import "UIView+SGCore.h"
#import <objc/runtime.h>

static inline void SGCoreSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector) {
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

@implementation UIView (SGCore)

#pragma mark - getter

- (CGSize)sg_size
{
    return self.frame.size;
}

- (CGPoint)sg_origin
{
    return self.frame.origin;
}

- (CGFloat)sg_x
{
    return self.sg_origin.x;
}

- (CGFloat)sg_y
{
    return self.sg_origin.y;
}

- (CGFloat)sg_width
{
    return self.sg_size.width;
}

- (CGFloat)sg_height
{
    return self.sg_size.height;
}

- (CGFloat)sg_centerX
{
    return self.center.x;
}

- (CGFloat)sg_centerY
{
    return self.center.y;
}

- (CGFloat)sg_top
{
    return self.sg_y;
}

- (CGFloat)sg_left
{
    return self.sg_x;
}

- (CGFloat)sg_bottom
{
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)sg_right
{
    return CGRectGetMaxX(self.frame);
}

#pragma mark - setter

- (void)setSg_size:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setSg_origin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setSg_x:(CGFloat)x
{
    self.sg_origin = CGPointMake(x, self.sg_y);
}

- (void)setSg_y:(CGFloat)y
{
    self.sg_origin = CGPointMake(self.sg_x, y);
}

- (void)setSg_width:(CGFloat)width
{
    self.sg_size = CGSizeMake(width, self.sg_height);
}

- (void)setSg_height:(CGFloat)height
{
    self.sg_size = CGSizeMake(self.sg_width, height);
}

- (void)setSg_centerX:(CGFloat)centerX
{
    self.center = CGPointMake(centerX, self.sg_centerY);
}

- (void)setSg_centerY:(CGFloat)centerY
{
    self.center = CGPointMake(self.sg_centerX, centerY);
}

- (void)setSg_top:(CGFloat)top
{
    self.sg_y = top;
}

- (void)setSg_left:(CGFloat)left
{
    self.sg_x = left;
}

- (void)setSg_bottom:(CGFloat)bottom
{
    CGFloat offsetY = bottom - self.sg_bottom;
    self.sg_y += offsetY;
}

- (void)setSg_right:(CGFloat)right
{
    CGFloat offsetX = right - self.sg_right;
    self.sg_x += offsetX;
}

#pragma mark - Set AnchorPoint

- (void)sg_setPosition:(CGPoint)point anchorPoint:(CGPoint)anchorPoint
{
    CGFloat x = point.x - anchorPoint.x * self.sg_width;
    CGFloat y = point.y - anchorPoint.y * self.sg_height;
    self.sg_origin = CGPointMake(x, y);
}

@end

@implementation UIView (SGClipsBounds)

- (UIView * _Nonnull (^)(UIRectCorner, CGFloat))sg_clipsToBounds {
    return ^(UIRectCorner corners, CGFloat cornerRadius) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        CAShapeLayer *maskLayer = CAShapeLayer.layer;
        maskLayer.frame = self.bounds;
        maskLayer.path = bezierPath.CGPath;
        self.layer.mask = maskLayer;
        return self;
    };
}

@end

static NSInteger const SGAccessoryViewPlaceholderTag = 1538031855;

@implementation UIView (SGAccessoryView)

- (UIToolbar *)sg_customAccessoryView {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 35.0f)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *completionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [completionButton setTitle:@"完成" forState:UIControlStateNormal];
    [completionButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
    completionButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [completionButton addTarget:self action:@selector(sg_returnKeyboard) forControlEvents:UIControlEventTouchUpInside];
    completionButton.sg_size = CGSizeMake(50.0f, toolbar.sg_height);
    
    UIBarButtonItem *completionItem = [[UIBarButtonItem alloc] initWithCustomView:completionButton];
    toolbar.items = @[spaceItem, spaceItem, completionItem];
    
    UILabel *placeholderLabel = [[UILabel alloc] init];
    placeholderLabel.text = @"请输入";
    placeholderLabel.textColor = [UIColor colorWithRed:152/255.0 green:152/255.0 blue:152/255.0 alpha:1.0f];
    placeholderLabel.font = [UIFont systemFontOfSize:14.0f];
    placeholderLabel.numberOfLines = 1;
    placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    placeholderLabel.sg_size = CGSizeMake(UIScreen.mainScreen.bounds.size.width * 0.7, toolbar.sg_height);
    [placeholderLabel sg_setPosition:CGPointMake(15.0f, 0) anchorPoint:CGPointZero];
    placeholderLabel.tag = SGAccessoryViewPlaceholderTag;
        
    return toolbar;
}

- (void)sg_returnKeyboard {
    [UIApplication.sharedApplication.delegate.window endEditing:YES];
}

@end

@implementation UITextField (SGAccessoryView)

+ (void)load {
    SGCoreSwizzleSelector(self, @selector(init), @selector(sg_accessory_init));
    SGCoreSwizzleSelector(self, @selector(initWithFrame:), @selector(sg_accessory_initWithFrame:));
    SGCoreSwizzleSelector(self, @selector(initWithCoder:), @selector(sg_accessory_initWithCoder:));
}

- (instancetype)sg_accessory_init
{
    if ([self sg_accessory_init]) {
        [self addTouchDownTarget];
    }
    return self;
}

- (instancetype)sg_accessory_initWithFrame:(CGRect)frame
{
    if ([self sg_accessory_initWithFrame:frame]) {
        [self addTouchDownTarget];
    }
    return self;
}

- (instancetype)sg_accessory_initWithCoder:(NSCoder *)aDecoder
{
    if ([self sg_accessory_initWithCoder:aDecoder]) {
        [self addTouchDownTarget];
    }
    return self;
}

- (void)addTouchDownTarget {
    [self addTarget:self action:@selector(changeAccessoryViewPlaceHolder) forControlEvents:UIControlEventEditingDidBegin];
}

- (void)changeAccessoryViewPlaceHolder {
    if ([self.inputAccessoryView isKindOfClass:[UIToolbar class]]) {
        UIToolbar *toolBar = (UIToolbar *)self.inputAccessoryView;
        if ([toolBar viewWithTag:SGAccessoryViewPlaceholderTag] && [[toolBar viewWithTag:SGAccessoryViewPlaceholderTag] isKindOfClass:[UILabel class]]) {
            UILabel *placeholderLB = ((UILabel *)[toolBar viewWithTag:SGAccessoryViewPlaceholderTag]);
            placeholderLB.text = [self.placeholder isEqualToString:@""] ? @"请输入" : self.placeholder;
        }
    }
}

@end

@implementation UITextView (SGAccessoryView)

+ (void)load {
    SGCoreSwizzleSelector(self, @selector(init), @selector(sg_accessory_init));
    SGCoreSwizzleSelector(self, @selector(initWithFrame:), @selector(sg_accessory_initWithFrame:));
    SGCoreSwizzleSelector(self, @selector(initWithCoder:), @selector(sg_accessory_initWithCoder:));
}

- (instancetype)sg_accessory_init
{
    if ([self sg_accessory_init]) {
        [self addTouchDownTarget];
    }
    return self;
}

- (instancetype)sg_accessory_initWithFrame:(CGRect)frame
{
    if ([self sg_accessory_initWithFrame:frame]) {
        [self addTouchDownTarget];
    }
    return self;
}

- (instancetype)sg_accessory_initWithCoder:(NSCoder *)aDecoder
{
    if ([self sg_accessory_initWithCoder:aDecoder]) {
        [self addTouchDownTarget];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self changeAccessoryViewPlaceHolder];
}

- (void)addTouchDownTarget {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(changeAccessoryViewPlaceHolder) name:UITextViewTextDidBeginEditingNotification object:nil];
}

- (void)changeAccessoryViewPlaceHolder {
//    if ([self.inputAccessoryView isKindOfClass:[UIToolbar class]]) {
//        UIToolbar *toolBar = (UIToolbar *)self.inputAccessoryView;
//        if ([toolBar viewWithTag:SGAccessoryViewPlaceholderTag] && [[toolBar viewWithTag:SGAccessoryViewPlaceholderTag] isKindOfClass:[UILabel class]]) {
//            UILabel *placeholderLB = ((UILabel *)[toolBar viewWithTag:SGAccessoryViewPlaceholderTag]);
//            placeholderLB.text = [self.placeholderStr isEqualToString:@""] ? @"请输入" : self.placeholderStr;
//        }
//    }
}

@end
