//
//  SGVocabularyAnswerView.h
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGVocabularyAnswerView : UIView

@property (nonatomic, strong) NSString *rightAnswer;

- (void)resetLookAnswerButton;

- (void)showAnswerView;
- (void)hideAnswerView;

@end

NS_ASSUME_NONNULL_END
