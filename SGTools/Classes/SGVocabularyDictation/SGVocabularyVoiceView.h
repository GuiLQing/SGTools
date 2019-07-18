//
//  SGVocabularyVoiceView.h
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/18.
//  Copyright © 2019 lg. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGVocabularyVoiceView : UIView

@property (nonatomic, copy) void (^voiceImageDidClicked)(void (^handleVoiceAnimation)(BOOL isToStart));

@end

NS_ASSUME_NONNULL_END
