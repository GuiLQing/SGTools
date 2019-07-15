//
//  SGSearchController.h
//  SGSearchController
//
//  Created by lg on 2019/7/8.
//  Copyright © 2019 lg. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGSearchController : UITableViewController

/**
 搜索控制器
 
 @param defaultText 默认搜索关键字
 @param placeholderText 占位字符
 @param historySaveKey 存储key -> "UIViewController"
 */
- (instancetype)initWithDefaultText:(NSString *)defaultText placeholderText:(NSString *)placeholderText historySaveKey:(NSString *)historySaveKey;

/** 占位提示语*/
@property (nonatomic, copy) NSString *placeholderStr;

/** 搜索回调*/
@property (nonatomic, copy) void(^searchCallBack)(NSString *searchStr);

@property (nonatomic, copy) void(^cancelCallBack)(void);

@end

NS_ASSUME_NONNULL_END
