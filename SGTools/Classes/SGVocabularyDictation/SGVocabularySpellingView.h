//
//  SGVocabularySpellingView.h
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SGVocabularySpellingViewDelegate <NSObject>

@optional

/** 触发删除事件回调 */
- (void)sg_spellingViewDeleteDidClickedWithWords:(NSString *)words;

- (void)sg_spellingViewCallbackSpellingAnswer:(NSString *)answer;

@end

@interface SGVocabularySpellingView : UIView

@property (nonatomic, strong) NSArray<NSArray *> *rightVocabularys;

@property (nonatomic, weak) id<SGVocabularySpellingViewDelegate> delegate;

@property (nonatomic, assign, readonly) NSInteger needAnswerCount;

- (BOOL)addSpellingAnswer:(NSString *)answer;

@end

NS_ASSUME_NONNULL_END
