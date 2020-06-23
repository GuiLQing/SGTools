//
//  UIViewController+SGBase.m
//  AFNetworking
//
//  Created by lancoo on 2020/3/27.
//

#import "UIViewController+SGBase.h"
#include <objc/runtime.h>
#import <Masonry/Masonry.h>
#import "SGResource.h"

void SGBaseSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector) {
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

@interface UIViewController () <UINavigationControllerDelegate>

@end

@implementation UIViewController (SGBase)

+ (void)load {
    SGBaseSwizzleSelector(self.class, @selector(viewWillAppear:), @selector(SGBase_viewWillAppear:));
    SGBaseSwizzleSelector(self.class, @selector(viewWillDisappear:), @selector(SGBase_viewWillDisappear:));
    
    SGBaseSwizzleSelector(self.class, @selector(viewDidAppear:), @selector(SGBase_viewDidAppear:));
    SGBaseSwizzleSelector(self.class, @selector(viewDidDisappear:), @selector(SGBase_viewDidDisappear:));
}

- (void)SGBase_viewWillAppear:(BOOL)animated {
    [self SGBase_viewWillAppear:animated];
    
    /** 设置屏幕常亮 */
    if (self.sg_isKeepScreenOn) {
        [UIApplication.sharedApplication setIdleTimerDisabled:YES];
    }
    /// 隐藏导航栏
    if (self.sg_isHideNavigationBar) {
        self.navigationController.delegate = self;
    }
}

- (void)SGBase_viewWillDisappear:(BOOL)animated {
    [self SGBase_viewWillDisappear:animated];
    
    /** 关闭屏幕常亮 */
    [UIApplication.sharedApplication setIdleTimerDisabled:NO];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && self.sg_isCloseSystemSideslip) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)SGBase_viewDidAppear:(BOOL)animated {
    [self SGBase_viewDidAppear:animated];
    
    if (self.sg_isRegisteredKeyboardObserve) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sg_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sg_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && self.sg_isCloseSystemSideslip) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)SGBase_viewDidDisappear:(BOOL)animated {
    [self SGBase_viewDidDisappear:animated];
    
    if (self.sg_isRegisteredKeyboardObserve) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)sg_keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = [self.view convertRect:keyboardRect fromView:nil].size.height;
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if ([self respondsToSelector:@selector(sg_keyboardWillShowWithKeyboardHeight:duration:)]) {
        [self sg_keyboardWillShowWithKeyboardHeight:keyboardHeight duration:duration];
    }
}

- (void)sg_keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if ([self respondsToSelector:@selector(sg_keyboardWillHideWithDuration:)]) {
        [self sg_keyboardWillHideWithDuration:duration];
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:[viewController isKindOfClass:[self class]] animated:YES];
}

#pragma mark - Property

- (void)setSg_isRegisteredKeyboardObserve:(BOOL)sg_isRegisteredKeyboardObserve {
    objc_setAssociatedObject(self, @selector(sg_isRegisteredKeyboardObserve), [NSNumber numberWithBool:sg_isRegisteredKeyboardObserve], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sg_isRegisteredKeyboardObserve {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSg_isKeepScreenOn:(BOOL)sg_isKeepScreenOn {
    objc_setAssociatedObject(self, @selector(sg_isKeepScreenOn), [NSNumber numberWithBool:sg_isKeepScreenOn], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sg_isKeepScreenOn {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSg_isCloseSystemSideslip:(BOOL)sg_isCloseSystemSideslip {
    objc_setAssociatedObject(self, @selector(sg_isCloseSystemSideslip), [NSNumber numberWithBool:sg_isCloseSystemSideslip], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sg_isCloseSystemSideslip {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSg_isHideNavigationBar:(BOOL)sg_isHideNavigationBar {
    objc_setAssociatedObject(self, @selector(sg_isHideNavigationBar), [NSNumber numberWithBool:sg_isHideNavigationBar], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sg_isHideNavigationBar {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

@interface UIViewController ()

@property (nonatomic, strong, readonly) UIView *sg_loadingView;

@property (nonatomic, strong, readonly) UIView *sg_emptyView;

@property (nonatomic, strong, readonly) UIView *sg_errorView;

@end

@implementation UIViewController (SGLoad)

- (void)sg_resetLoadView {
    [self.sg_loadingView removeFromSuperview];
    [self.sg_emptyView removeFromSuperview];
    [self.sg_errorView removeFromSuperview];
}

- (void)sg_showLoadView:(UIView *)loadView {
    [self.view addSubview:loadView];
    [self.view bringSubviewToFront:loadView];
    [loadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        if (self.sg_isHideNavigationBar) {
            make.top.equalTo(self.view).offset(UIApplication.sharedApplication.delegate.window.safeAreaInsets.top + 44.0f);
        } else {
            make.top.equalTo(self.view);
        }
    }];
}

- (void)sg_showLoadingView {
    [self sg_resetLoadView];
    [self sg_showLoadView:self.sg_loadingView];
}

- (void)sg_showLoadEmptyView {
    [self sg_resetLoadView];
    [self sg_showLoadView:self.sg_emptyView];
}

- (void)sg_showLoadErrorView {
    [self sg_resetLoadView];
    [self sg_showLoadView:self.sg_errorView];
}

- (void)sg_updateLoadEmptyTitle:(NSString *)emptyTitle {
    for (id obj in self.sg_emptyView.subviews) {
        if ([obj isKindOfClass:UILabel.class]) {
            UILabel *titleLabel = obj;
            titleLabel.text = emptyTitle;
        }
    }
}

- (void)sg_updateLoadErrorTitle:(NSString *)errorTitle {
    for (id obj in self.sg_errorView.subviews) {
        if ([obj isKindOfClass:UILabel.class]) {
            UILabel *titleLabel = obj;
            titleLabel.text = errorTitle;
        }
    }
}

- (UIView *)sg_loadingView {
    UIView *loadingView = objc_getAssociatedObject(self, _cmd);
    if (!loadingView) {
        loadingView = [[UIView alloc] init];
        loadingView.backgroundColor = UIColor.whiteColor;
        
        UIImageView *loadingIV = [[UIImageView alloc] init];
        UIImage *defaultImage = SGResource.sg_defaultResource.sg_loadingImages.firstObject;
        loadingIV.animationImages = SGResource.sg_defaultResource.sg_loadingImages;
        [loadingIV startAnimating];
        [loadingView addSubview:loadingIV];
        [loadingIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(loadingView.mas_centerX);
            make.centerY.equalTo(loadingView.mas_centerY).offset(-15.0f);
            make.height.equalTo(loadingIV.mas_width).multipliedBy(defaultImage.size.height / defaultImage.size.width);
            make.width.mas_equalTo(100.0f);
        }];
        
        UILabel *loadingLabel = [[UILabel alloc] init];
        loadingLabel.font = [UIFont systemFontOfSize:14.0f];
        loadingLabel.text = @"努力加载中...";
        loadingLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        [loadingView addSubview:loadingLabel];
        [loadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(loadingIV.mas_centerX);
            make.top.equalTo(loadingIV.mas_bottom).offset(15.0f);
        }];
        
        objc_setAssociatedObject(self, _cmd, loadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return loadingView;
}

- (UIView *)sg_emptyView {
    UIView *emptyView = objc_getAssociatedObject(self, _cmd);
    if (!emptyView) {
        emptyView = [[UIView alloc] init];
        emptyView.backgroundColor = UIColor.whiteColor;
        
        UIImageView *emptyIV = [[UIImageView alloc] init];
        UIImage *emptyImage = SGResource.sg_defaultResource.sg_loadEmptyImage;
        emptyIV.image = emptyImage;
        [emptyView addSubview:emptyIV];
        [emptyIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(emptyView.mas_centerX);
            make.centerY.equalTo(emptyView.mas_centerY).offset(-15.0f);
            make.height.equalTo(emptyIV.mas_width).multipliedBy(emptyImage.size.height / emptyImage.size.width);
            make.width.mas_equalTo(100.0f);
        }];
        
        UILabel *emptyLabel = [[UILabel alloc] init];
        emptyLabel.font = [UIFont systemFontOfSize:14.0f];
        emptyLabel.text = @"暂无数据";
        emptyLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        [emptyView addSubview:emptyLabel];
        [emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(emptyIV.mas_centerX);
            make.top.equalTo(emptyIV.mas_bottom).offset(15.0f);
        }];
        
        [emptyView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sg_reloadDataTapAction)]];
        
        objc_setAssociatedObject(self, _cmd, emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return emptyView;
}

- (UIView *)sg_errorView {
    UIView *errorView = objc_getAssociatedObject(self, _cmd);
    if (!errorView) {
        errorView = [[UIView alloc] init];
        errorView.backgroundColor = UIColor.whiteColor;
        
        UIImageView *errorIV = [[UIImageView alloc] init];
        UIImage *errorImage = SGResource.sg_defaultResource.sg_loadErrorImage;
        errorIV.image = errorImage;
        [errorView addSubview:errorIV];
        [errorIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(errorView.mas_centerX);
            make.centerY.equalTo(errorView.mas_centerY).offset(-15.0f);
            make.height.equalTo(errorIV.mas_width).multipliedBy(errorImage.size.height / errorImage.size.width);
            make.width.mas_equalTo(100.0f);
        }];
        
        UILabel *errorLabel = [[UILabel alloc] init];
        errorLabel.font = [UIFont systemFontOfSize:14.0f];
        errorLabel.text = @"数据加载异常，请稍后再试！";
        errorLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
        errorLabel.textAlignment = NSTextAlignmentCenter;
        [errorView addSubview:errorLabel];
        [errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(errorIV.mas_centerX);
            make.top.equalTo(errorIV.mas_bottom).offset(15.0f);
        }];
        
        [errorView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sg_reloadDataTapAction)]];
        
        objc_setAssociatedObject(self, _cmd, errorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return errorView;
}

- (void)sg_reloadDataTapAction {
    if ([self respondsToSelector:@selector(sg_reloadDataEventCallback)]) {
        [self sg_reloadDataEventCallback];
    }
}

@end
