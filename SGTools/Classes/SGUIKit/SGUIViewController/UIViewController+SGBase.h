//
//  UIViewController+SGBase.h
//  AFNetworking
//
//  Created by lancoo on 2020/3/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

void SGBaseSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector);

@protocol SGKeyboardDelegate <NSObject>

@optional

/// 键盘将要弹起回调
/// @param keyboardHeight 键盘高度
/// @param duration 弹起持续时间
- (void)sg_keyboardWillShowWithKeyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration;

/// 键盘将要收起回调
/// @param duration 收起持续时间
- (void)sg_keyboardWillHideWithDuration:(NSTimeInterval)duration;

@end

@protocol SGLoadDelegate <NSObject>

- (void)sg_reloadDataEventCallback;

@end

@interface UIViewController (SGBase) <SGKeyboardDelegate, SGLoadDelegate>

/// 是否注册键盘监听
@property (nonatomic, assign) BOOL sg_isRegisteredKeyboardObserve;
/// 保持屏幕常亮
@property (nonatomic, assign) BOOL sg_isKeepScreenOn;
/// 是否关闭系统侧滑
@property (nonatomic, assign) BOOL sg_isCloseSystemSideslip;
/// 是否隐藏导航栏
@property (nonatomic, assign) BOOL sg_isHideNavigationBar;

@end

@interface UIViewController (SGLoad)

/// 隐藏加载视图
- (void)sg_resetLoadView;
/// 显示加载动画视图
- (void)sg_showLoadingView;
/// 显示加载空数据视图
- (void)sg_showLoadEmptyView;
/// 显示加载失败视图
- (void)sg_showLoadErrorView;

- (void)sg_updateLoadEmptyTitle:(NSString *)emptyTitle;

- (void)sg_updateLoadErrorTitle:(NSString *)errorTitle;

@end

NS_ASSUME_NONNULL_END
