//
//  SGAlertView.h
//  SGAlertView
//
//  Created by SG on 2019/11/7.
//  Copyright © 2019 SG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SGAlertViewImageType) {
    SGAlertViewImageTypeNone,
    SGAlertViewImageTypeLancooNormal,
    SGAlertViewImageTypeLancooSubmit,
    SGAlertViewImageTypeCustom,
};

NS_ASSUME_NONNULL_BEGIN

@interface SGAlertTitleConfig : NSObject

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, strong) NSNumber *borderWidth;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) UIColor *backgroundColor;

@end

@interface SGAlertView : UIView

+ (SGAlertView *)sg_alertView;

- (SGAlertView * (^)(NSString * _Nullable title))sg_title;

- (SGAlertView * (^)(NSString * _Nullable message))sg_message;

- (SGAlertView * (^)(NSString * _Nullable ensureTitle))sg_ensureTitle;

- (SGAlertView * (^)(NSString * _Nullable cancelTitle))sg_cancelTitle;

- (SGAlertView * (^)(NSArray * _Nullable otherTitles))sg_otherTitles;

- (SGAlertView * (^)(void (^ _Nullable ensureHandle)(void)))sg_ensureHandle;

- (SGAlertView * (^)(void (^ _Nullable cancelHandle)(void)))sg_cancelHandle;

- (SGAlertView * (^)(void (^ _Nullable otherHandle)(NSNumber *index)))sg_otherHandle;

- (SGAlertView * (^)(void (^ _Nullable sg_config)(SGAlertTitleConfig *config)))sg_ensureTitleConfig;

- (SGAlertView * (^)(void (^ _Nullable sg_config)(SGAlertTitleConfig *config)))sg_cancelTitleConfig;

- (SGAlertView * (^)(NSArray<SGAlertTitleConfig *> * _Nullable otherTitleConfigs))sg_otherTitleConfigs;

- (SGAlertView * (^)(NSNumber * _Nullable imageType))sg_imageType;

- (SGAlertView * (^)(UIImage * _Nullable tipsImage))sg_tipsImage;

- (SGAlertView * (^)(void))sg_show;

- (SGAlertView * (^)(void))sg_hide;

+ (void)sg_dismiss;

@end

static inline SGAlertTitleConfig * SGAlertTitleConfigMake(UIFont * _Nullable font, UIColor * _Nullable titleColor, UIColor * _Nullable borderColor, NSNumber * _Nullable borderWidth, UIColor * _Nullable tintColor, UIColor * _Nullable backgroundColor) {
    SGAlertTitleConfig *config = [[SGAlertTitleConfig alloc] init];
    config.font = font;
    config.titleColor = titleColor;
    config.borderColor = borderColor;
    config.borderWidth = borderWidth;
    config.tintColor = tintColor;
    config.backgroundColor = backgroundColor;
    return config;
}

static inline SGAlertView * SGAlertViewShow(NSString * _Nullable title, NSString * _Nullable message, NSString * _Nullable ensureTitle, NSString * _Nullable cancelTitle, NSArray * _Nullable otherTitles, NSNumber * _Nullable imageType, UIImage * _Nullable tipsImage, void (^ _Nullable sg_ensureTitleConfig)(SGAlertTitleConfig *ensureTitleConfig), void (^ _Nullable sg_cancelTitleConfig)(SGAlertTitleConfig *cancelTitleConfig), NSArray<SGAlertTitleConfig *> * _Nullable otherTitleConfigs, void (^ _Nullable ensureHandle)(void), void (^ _Nullable cancelHandle)(void), void (^ _Nullable otherHandle)(NSNumber *index)) {
    return SGAlertView
    .sg_alertView
    .sg_title(title)
    .sg_message(message)
    .sg_ensureTitle(ensureTitle)
    .sg_cancelTitle(cancelTitle)
    .sg_otherTitles(otherTitles)
    .sg_imageType(imageType)
    .sg_tipsImage(tipsImage)
    .sg_ensureTitleConfig(sg_ensureTitleConfig)
    .sg_otherTitleConfigs(otherTitleConfigs)
    .sg_cancelTitleConfig(sg_cancelTitleConfig)
    .sg_ensureHandle(ensureHandle)
    .sg_cancelHandle(cancelHandle)
    .sg_otherHandle(otherHandle)
    .sg_show();
}

static inline SGAlertView * SGAlertViewLancooNormalShow(NSString * _Nullable title, NSString * _Nullable message, NSString * _Nullable ensureTitle, NSString * _Nullable cancelTitle, void (^ _Nullable ensureHandle)(void), void (^ _Nullable cancelHandle)(void)) {
    return SGAlertViewShow(title, message, ensureTitle, cancelTitle, nil, @(SGAlertViewImageTypeLancooNormal), nil, nil, nil, nil, ensureHandle, cancelHandle, nil);
}

static inline SGAlertView * SGAlertViewLancooSubmitShow(NSString * _Nullable title, NSString * _Nullable message, NSString * _Nullable ensureTitle, NSString * _Nullable cancelTitle, void (^ _Nullable ensureHandle)(void), void (^ _Nullable cancelHandle)(void)) {
    return SGAlertViewShow(title, message, ensureTitle, cancelTitle, nil, @(SGAlertViewImageTypeLancooSubmit), nil, nil, nil, nil, ensureHandle, cancelHandle, nil);
}

NS_ASSUME_NONNULL_END
