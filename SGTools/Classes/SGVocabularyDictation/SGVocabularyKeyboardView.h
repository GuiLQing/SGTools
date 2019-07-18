//
//  SGVocabularyKeyboardView.h
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SGVocabularyKeyboardViewDelegate <NSObject>

@optional

/** 点击回车按钮 */
- (void)sg_keyboardEnsureDidClicked;
/** 选中单词回调 */
- (void)sg_keyboardDidSelectedWithWords:(NSString *)words atIndex:(NSInteger)index complete:(void(^)(void))complete;

@end

@interface SGVocabularyKeyboardView : UIView

@property (nonatomic, strong) NSArray<NSString *> *randomVocabularys;

@property (nonatomic, weak) id<SGVocabularyKeyboardViewDelegate> delegate;

- (void)removeWords:(NSString *)words;

@end

NS_ASSUME_NONNULL_END
