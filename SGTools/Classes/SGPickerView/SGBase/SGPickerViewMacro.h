//
//  SGPickerViewMacro.h
//  SGPickerViewDemo
//
//  Created by 任波 on 2018/4/23.
//  Copyright © 2018年 91renb. All rights reserved.
//

#ifndef SGPickerViewMacro_h
#define SGPickerViewMacro_h

// 屏幕大小、宽、高
#ifndef SG_SCREEN_BOUNDS
#define SG_SCREEN_BOUNDS [UIScreen mainScreen].bounds
#endif
#ifndef SG_SCREEN_WIDTH
#define SG_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#endif
#ifndef SG_SCREEN_HEIGHT
#define SG_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#endif

// RGB颜色(16进制)
#define SG_RGB_HEX(rgbValue, a) \
[UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((CGFloat)(rgbValue & 0xFF)) / 255.0 alpha:(a)]

#define SG_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SG_IS_PAD (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)

// 等比例适配系数
#define SG_kScaleFit (SG_IS_IPHONE ? ((SG_SCREEN_WIDTH < SG_SCREEN_HEIGHT) ? SG_SCREEN_WIDTH / 375.0f : SG_SCREEN_WIDTH / 667.0f) : 1.1f)

#define SG_kPickerHeight 216
#define SG_kTopViewHeight 44

// 状态栏的高度(20 / 44(iPhoneX))
#define SG_STATUSBAR_HEIGHT ([UIApplication sharedApplication].statusBarFrame.size.height)
#define SG_IS_iPhoneX ((SG_STATUSBAR_HEIGHT == 44) ? YES : NO)
// 底部安全区域远离高度
#define SG_BOTTOM_MARGIN ((CGFloat)(SG_IS_iPhoneX ? 34 : 0))

// 默认主题颜色
#define SG_kDefaultThemeColor SG_RGB_HEX(0x464646, 1.0)
// topView视图的背景颜色
#define SG_kToolBarColor SG_RGB_HEX(0xFDFDFD, 1.0f)

// 静态库中编写 Category 时的便利宏，用于解决 Category 方法从静态库中加载需要特别设置的问题
#ifndef SGSYNTH_DUMMY_CLASS

#define SGSYNTH_DUMMY_CLASS(_name_) \
@interface SGSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation SGSYNTH_DUMMY_CLASS_ ## _name_ @end

#endif

// 过期提醒
#define SGPickerViewDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

// 打印错误日志
#define SGErrorLog(...) NSLog(@"reason: %@", [NSString stringWithFormat:__VA_ARGS__])

/**
 合成弱引用/强引用
 
 Example:
     @weakify(self)
     [self doSomething^{
         @strongify(self)
         if (!self) return;
         ...
     }];
 
 */
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

#endif /* SGPickerViewMacro_h */
