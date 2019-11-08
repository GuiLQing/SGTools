//
//  SGAlertView.m
//  SGAlertView
//
//  Created by SG on 2019/11/7.
//  Copyright © 2019 SG. All rights reserved.
//

#import "SGAlertView.h"
#import <Masonry/Masonry.h>

static NSInteger const SGAlertEnsureTag = 1573117264;
static NSInteger const SGAlertCancelTag = 1573117265;

static inline BOOL SGAlertIsEmptyString(NSString * _Nullable string) {
    return (string == nil || [string isKindOfClass:NSNull.class] || [string isEqual:NSNull.null] || [string isEqualToString:@""]);
}

static inline BOOL SGAlertIsEmptyArray(NSArray * _Nullable array) {
    return (array == nil || [array isKindOfClass:NSNull.class] || [array isEqual:NSNull.null] || array.count == 0);
}

static inline BOOL SGAlertIsEmptyObject(id _Nullable obj) {
    return (obj == nil || [obj isKindOfClass:NSNull.class] || [obj isEqual:NSNull.null]);
}

static inline UIColor * _Nullable SGAlertHexColor(NSInteger c) {
    return [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f];
}

static inline UIFont * _Nonnull SGAlertFontDynamicSize(CGFloat size) {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) size += 3.0f;
    return [UIFont systemFontOfSize:size];
}

static inline NSMutableAttributedString * _Nullable SGAlertAttributedString(NSString *text) {
    if (SGAlertIsEmptyString(text)) return nil;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5.0f;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
    return attributedString;
}

static inline void SGAlertTopBorder(UIView *view, UIColor *color, CGFloat width) {
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = color;
    [view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(view);
        make.height.mas_equalTo(width);
    }];
}

static inline void SGAlertRounder(UIView *view, CGFloat radius) {
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

static inline void SGAlertBorder(UIView *view, UIColor *color, CGFloat width) {
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = width;
}

@implementation NSBundle (SGAlertResource)

+ (NSBundle *)sg_alert_default_bundle {
    static NSBundle *_alert_default_bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _alert_default_bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:SGAlertView.class] pathForResource:@"SGAlert" ofType:@"bundle"]];
    });
    return _alert_default_bundle;
}

@end

static inline NSString * SGAlertBundlePath(NSString *resourceName) {
    return [NSBundle.sg_alert_default_bundle.resourcePath stringByAppendingPathComponent:resourceName];
}

static inline UIImage * SGAlertImage(NSString *imageName) {
    return [UIImage imageNamed:SGAlertBundlePath(imageName)];
}

@implementation SGAlertTitleConfig

@end

@interface SGAlertTitle : NSObject

@property (nonatomic, assign) NSInteger titleTag;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) SGAlertTitleConfig *titleConfig;

@end

@implementation SGAlertTitle

@end

static inline SGAlertTitle * SGAlertTitleMake(NSInteger tag, NSString *title, SGAlertTitleConfig * _Nullable titleConfig) {
    SGAlertTitle *alertTitle = [[SGAlertTitle alloc] init];
    alertTitle.titleTag = tag;
    alertTitle.title = title;
    alertTitle.titleConfig = titleConfig;
    return alertTitle;
}

@interface SGAlertView ()

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *alertView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) NSString *ensureTitle;

@property (nonatomic, strong) NSString *cancelTitle;

@property (nonatomic, strong) NSArray *otherTitles;

@property (nonatomic, strong) UIImage *tipsImage;

@property (nonatomic, assign) SGAlertViewImageType imageType;

@property (nonatomic, strong) void (^ensureHandle)(void);

@property (nonatomic, strong) void (^cancelHandle)(void);

@property (nonatomic, strong) void (^otherHandle)(NSNumber *index);

@property (nonatomic, strong) SGAlertTitleConfig *ensureTitleConfig;

@property (nonatomic, strong) SGAlertTitleConfig *cancelTitleConfig;

@property (nonatomic, strong) NSArray<SGAlertTitleConfig *> *otherTitleConfigs;

@property (nonatomic, strong) NSMutableDictionary *alertItems;

@end

@implementation SGAlertView

- (void)dealloc {
    NSLog(@"SGAlertView dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _window = UIApplication.sharedApplication.delegate.window;
        
        self.frame = _window.bounds;
    }
    return self;
}

- (void)setupSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _maskView = [[UIView alloc] initWithFrame:self.bounds];
    _maskView.backgroundColor = UIColor.blackColor;
    [self addSubview:_maskView];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [_maskView addGestureRecognizer:tapGR];
    
    _alertView = [[UIView alloc] init];
    [self addSubview:_alertView];
    [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            make.width.equalTo(self.mas_width).multipliedBy(8.0 / 15);
        } else {
            make.left.equalTo(self.mas_left).offset(40.0f);
            make.right.equalTo(self.mas_right).offset(-40.0f);
        }
    }];
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = UIColor.whiteColor;
    _contentView.layer.cornerRadius = 6.0f;
    _contentView.layer.masksToBounds = YES;
    [_alertView addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self);
        make.left.bottom.right.equalTo(self.alertView);
        make.top.mas_greaterThanOrEqualTo(self.alertView.mas_top);
        make.height.mas_greaterThanOrEqualTo(100.0f);
    }];
    
    UIImageView *tipsIV = nil;
    if (_imageType != SGAlertViewImageTypeNone) {
        UIImage *tipsImage = self.tipsImage;
        if (_imageType == SGAlertViewImageTypeLancooNormal) {
            tipsImage = SGAlertImage(@"sg_alert_icon_lancoo_normal");
        } else if (_imageType == SGAlertViewImageTypeLancooSubmit) {
            tipsImage = SGAlertImage(@"sg_alert_icon_lancoo_submit");
        }
        if (!SGAlertIsEmptyObject(tipsImage)) {
            tipsIV = [[UIImageView alloc] initWithImage:tipsImage];
            [_alertView addSubview:tipsIV];
            [tipsIV mas_makeConstraints:^(MASConstraintMaker *make) {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ||
                    self.imageType == SGAlertViewImageTypeLancooNormal ||
                    self.imageType == SGAlertViewImageTypeLancooSubmit) {
                    make.width.mas_equalTo(150.0f);
                } else {
                    make.width.mas_equalTo(120.0f);
                }
                make.height.equalTo(tipsIV.mas_width).multipliedBy(tipsImage.size.height / tipsImage.size.width);
                make.top.mas_greaterThanOrEqualTo(self.alertView.mas_top);
                if (self.imageType == SGAlertViewImageTypeLancooSubmit) {
                    make.centerX.equalTo(self.alertView.mas_centerX).offset(20.0f);
                    make.bottom.equalTo(self.contentView.mas_top).offset(35.0f);
                } else {
                    make.centerX.equalTo(self.alertView.mas_centerX);
                    make.centerY.equalTo(self.contentView.mas_top);
                }
            }];
        }
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    titleLabel.attributedText = SGAlertAttributedString(self.title);
    titleLabel.textColor = SGAlertHexColor(0x252525);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    titleLabel.font = SGAlertFontDynamicSize(18.0f);
    [_contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (!SGAlertIsEmptyObject(tipsIV)) {
            if (self.imageType == SGAlertViewImageTypeLancooSubmit) {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    make.top.equalTo(self.contentView.mas_top).offset(50.0f);
                } else {
                    make.top.equalTo(self.contentView.mas_top).offset(40.0f);
                }
            } else {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    make.top.equalTo(self.contentView.mas_top).offset(85.0f);
                } else {
                    make.top.equalTo(self.contentView.mas_top).offset(65.0f);
                }
            }
        } else {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                make.top.equalTo(self.contentView.mas_top).offset(40.0f);
            } else {
                make.top.equalTo(self.contentView.mas_top).offset(20.0f);
            }
        }
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.left.mas_greaterThanOrEqualTo(self.contentView.mas_left).offset(40.0f);
        make.right.mas_lessThanOrEqualTo(self.contentView.mas_right).offset(-40.0f);
    }];
    
    UILabel *messageLabel = [[UILabel alloc] init];
    self.messageLabel = messageLabel;
    messageLabel.attributedText = SGAlertAttributedString(self.message);
    messageLabel.textColor = SGAlertHexColor(0x656565);
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.numberOfLines = 0;
    messageLabel.font = SGAlertFontDynamicSize(15.0f);
    [_contentView addSubview:messageLabel];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            make.top.equalTo(titleLabel.mas_bottom).offset(30.0f);
        } else {
            make.top.equalTo(titleLabel.mas_bottom).offset(20.0f);
        }
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.left.mas_greaterThanOrEqualTo(self.contentView.mas_left).offset(40.0f);
        make.right.mas_lessThanOrEqualTo(self.contentView.mas_right).offset(-40.0f);
    }];
    
    [self setupItemsContentView];
}

- (void)setupItemsContentView {
    NSMutableArray *itemTitles = [NSMutableArray array];
    if (!SGAlertIsEmptyString(self.ensureTitle)) {
        [itemTitles addObject:SGAlertTitleMake(SGAlertEnsureTag, self.ensureTitle, self.ensureTitleConfig)];
    }
    if (!SGAlertIsEmptyArray(self.otherTitles)) {
        for (NSInteger i = 0; i < self.otherTitles.count; i ++) {
            [itemTitles addObject:SGAlertTitleMake(i, self.otherTitles[i], self.otherTitleConfigs[i])];
        }
    }
    if (!SGAlertIsEmptyString(self.cancelTitle)) {
        [itemTitles addObject:SGAlertTitleMake(SGAlertCancelTag, self.cancelTitle, self.cancelTitleConfig)];
    }
    
    UIView *itemsContentView = [[UIView alloc] init];
    [_contentView addSubview:itemsContentView];
    [itemsContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            make.top.equalTo(self.messageLabel.mas_bottom).offset(40.0f);
        } else {
            make.top.equalTo(self.messageLabel.mas_bottom).offset(20.0f);
        }
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.left.mas_greaterThanOrEqualTo(self.contentView.mas_left);
        make.bottom.mas_lessThanOrEqualTo(self.contentView.mas_bottom);
        make.right.mas_lessThanOrEqualTo(self.contentView.mas_right);
    }];
    
    if (!SGAlertIsEmptyArray(itemTitles)) {
        _alertItems = [NSMutableDictionary dictionary];
        NSMutableArray *items = [NSMutableArray array];
        for (SGAlertTitle *itemTitle in itemTitles) {
            UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
            [item.titleLabel setFont:SGAlertFontDynamicSize(15.0f)];
            [item setTag:itemTitle.titleTag];
            [item setTitle:itemTitle.title forState:UIControlStateNormal];
            [item addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
            [itemsContentView addSubview:item];
            [items addObject:item];
            [_alertItems setObject:item forKey:[NSIndexPath indexPathWithIndex:itemTitle.titleTag]];
        }
        
        if (items.count == 1) {
            UIButton *item = items.firstObject;
            SGAlertRounder(item, 20.0f);
            item.backgroundColor = SGAlertHexColor(0x0baffb);
            
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(40.0f);
                make.width.equalTo(self.contentView.mas_width).multipliedBy(1.0 / 2);
                make.top.left.right.equalTo(itemsContentView);
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    make.bottom.equalTo(itemsContentView.mas_bottom).offset(-40.0f);
                } else {
                    make.bottom.equalTo(itemsContentView.mas_bottom).offset(-20.0f);
                }
            }];
        } else if (items.count == 2) {
            UIButton *firstItem = items.firstObject;
            SGAlertRounder(firstItem, 20.0f);
            firstItem.backgroundColor = SGAlertHexColor(0x0baffb);
            
            UIButton *lastItem = items.lastObject;
            SGAlertRounder(lastItem, 20.0f);
            SGAlertBorder(lastItem, SGAlertHexColor(0x0baffb), 1.0f);
            [lastItem setTitleColor:SGAlertHexColor(0x0baffb) forState:UIControlStateNormal];
            
            [items mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(40.0f);
                make.width.equalTo(self.contentView.mas_width).multipliedBy(2.0 / 5);
                make.top.mas_greaterThanOrEqualTo(itemsContentView.mas_top);
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    make.bottom.mas_lessThanOrEqualTo(itemsContentView.mas_bottom).offset(-40.0f);
                } else {
                    make.bottom.mas_lessThanOrEqualTo(itemsContentView.mas_bottom).offset(-20.0f);
                }
            }];
            [items.reverseObjectEnumerator.allObjects mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20.0f leadSpacing:0 tailSpacing:0];
        } else {
            for (UIButton *item in items) {
                SGAlertTopBorder(item, SGAlertHexColor(0xd9d9d9), 1.0);
                [item setTitleColor:SGAlertHexColor(0x252525) forState:UIControlStateNormal];
            }
            
            [items mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(40.0f);
                make.width.equalTo(self.contentView.mas_width);
                make.left.right.equalTo(itemsContentView);
                make.top.mas_greaterThanOrEqualTo(itemsContentView.mas_top);
                make.bottom.mas_lessThanOrEqualTo(itemsContentView.mas_bottom);
            }];
            [items mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        }
        
        [self updateAlertTitles:itemTitles];
    }
}

- (void)updateAlertTitles:(NSArray *)itemTitles {
    for (SGAlertTitle *itemTitle in itemTitles) {
        UIButton *item = [_alertItems objectForKey:[NSIndexPath indexPathWithIndex:itemTitle.titleTag]];
        SGAlertTitleConfig *config = itemTitle.titleConfig;
        if (item && !SGAlertIsEmptyObject(config)) {
            if (!SGAlertIsEmptyObject(config.font)) {
                [item.titleLabel setFont:config.font];
            }
            if (!SGAlertIsEmptyObject(config.titleColor)) {
                [item setTitleColor:config.tintColor forState:UIControlStateNormal];
            }
            if (!SGAlertIsEmptyObject(config.borderColor)) {
                [item.layer setBorderColor:config.tintColor.CGColor];
            }
            if (!SGAlertIsEmptyObject(config.borderWidth)) {
                [item.layer setBorderWidth:config.borderWidth.doubleValue];
            }
            if (!SGAlertIsEmptyObject(config.tintColor)) {
                [item.layer setBorderColor:config.tintColor.CGColor];
                [item setTitleColor:config.tintColor forState:UIControlStateNormal];
            }
            if (!SGAlertIsEmptyObject(config.backgroundColor)) {
                [item setBackgroundColor:config.backgroundColor];
            }
        }
    }
}

- (void)itemAction:(UIButton *)sender {
    if (sender.tag == SGAlertEnsureTag) {
        if (self.ensureHandle) self.ensureHandle();
    } else if (sender.tag == SGAlertCancelTag) {
        if (self.cancelHandle) self.cancelHandle();
    } else {
        if (self.otherHandle) self.otherHandle(@(sender.tag));
    }
    [self hide];
}

- (void)show {
    [self setupSubviews];
    [self.window addSubview:self];
    self.maskView.alpha = 0.0f;
    self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0f, 0.0f);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.maskView.alpha = 0.5;
        self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1f, 1.1f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
        }];
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.25 animations:^{
        self.maskView.alpha = 0.0f;
        self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1f, 1.1f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1f, 0.1f);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

+ (SGAlertView *)sg_alertView {
    return SGAlertView.alloc.init;
}

- (SGAlertView * (^)(NSString * _Nullable title))sg_title {
    return ^(NSString * _Nullable title) {
        self.title = title;
        return self;
    };
}

- (SGAlertView * (^)(NSString * _Nullable message))sg_message {
    return ^(NSString * _Nullable message) {
        self.message = message;
        return self;
    };
}

- (SGAlertView * (^)(NSString * _Nullable ensureTitle))sg_ensureTitle {
    return ^(NSString * _Nullable ensureTitle) {
        self.ensureTitle = ensureTitle;
        return self;
    };
}

- (SGAlertView * (^)(NSString * _Nullable cancelTitle))sg_cancelTitle {
    return ^(NSString * _Nullable cancelTitle) {
        self.cancelTitle = cancelTitle;
        return self;
    };
}

- (SGAlertView * (^)(NSArray * _Nullable otherTitles))sg_otherTitles {
    return ^(NSArray * _Nullable otherTitles) {
        self.otherTitles = otherTitles;
        return self;
    };
}

- (SGAlertView * (^)(void (^ _Nullable ensureHandle)(void)))sg_ensureHandle {
    return ^(void (^ _Nullable ensureHandle)(void)) {
        if (ensureHandle) self.ensureHandle = ensureHandle;
        return self;
    };
}

- (SGAlertView * (^)(void (^ _Nullable cancelHandle)(void)))sg_cancelHandle {
    return ^(void (^ _Nullable cancelHandle)(void)) {
        if (cancelHandle) self.cancelHandle = cancelHandle;
        return self;
    };
}

- (SGAlertView * (^)(void (^ _Nullable otherHandle)(NSNumber *index)))sg_otherHandle {
    return ^(void (^ _Nullable otherHandle)(NSNumber *index)) {
        if (otherHandle) self.otherHandle = otherHandle;
        return self;
    };
}

- (SGAlertView * (^)(void (^ _Nullable sg_config)(SGAlertTitleConfig *config)))sg_ensureTitleConfig {
    return ^(void (^ _Nullable sg_config)(SGAlertTitleConfig *config)) {
        if (sg_config) sg_config(self.ensureTitleConfig);
        return self;
    };
}

- (SGAlertView * (^)(void (^ _Nullable sg_config)(SGAlertTitleConfig *config)))sg_cancelTitleConfig {
    return ^(void (^ _Nullable sg_config)(SGAlertTitleConfig *config)) {
        if (sg_config) sg_config(self.cancelTitleConfig);
        return self;
    };
}

- (SGAlertView * (^)(NSArray<SGAlertTitleConfig *> * _Nullable otherTitleConfigs))sg_otherTitleConfigs {
    return ^(NSArray<SGAlertTitleConfig *> * _Nullable otherTitleConfigs) {
        self.otherTitleConfigs = otherTitleConfigs;
        return self;
    };
}

- (SGAlertView * (^)(NSNumber * _Nullable imageType))sg_imageType {
    return ^(NSNumber * _Nullable imageType) {
        self.imageType = imageType.integerValue;
        return self;
    };
}

- (SGAlertView * (^)(UIImage * _Nullable tipsImage))sg_tipsImage {
    return ^(UIImage * _Nullable tipsImage) {
        self.tipsImage = tipsImage;
        return self;
    };
}

- (SGAlertView * (^)(void))sg_show {
    return ^(void) {
        [self show];
        return self;
    };
}

- (SGAlertView * (^)(void))sg_hide {
    return ^(void) {
        [self hide];
        return self;
    };
}

+ (void)sg_dismiss {
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    for (UIView *view in window.subviews) {
        if ([view isKindOfClass:self.class]) {
            [view performSelector:@selector(hide)];
        }
    }
}

#pragma mark - Lazy Loading

- (SGAlertTitleConfig *)ensureTitleConfig {
    if (!_ensureTitleConfig) {
        _ensureTitleConfig = [[SGAlertTitleConfig alloc] init];
    }
    return _ensureTitleConfig;
}

- (SGAlertTitleConfig *)cancelTitleConfig {
    if (!_cancelTitleConfig) {
        _cancelTitleConfig = [[SGAlertTitleConfig alloc] init];
    }
    return _cancelTitleConfig;
}

@end
