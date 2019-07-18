//
//  SGVocabularyDictationView.h
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 听写视图中间视图显示类型 */
typedef NS_ENUM(NSUInteger, SGDictationViewType) {
    SGDictationViewTypeAnswer, //默认，答案视图
    SGDictationViewTypeVoice,  //音频视图
};

@interface SGVocabularyDictationView : UIView

/** 词汇拼写回调监听 */
@property (nonatomic, copy) void (^sg_dictationSpellAnswerCallback)(NSString *answer);

/** 键盘回车按钮事件 */
@property (nonatomic, copy) void (^sg_dictationEnsureDidClicked)(void);

/** 音频播放点击回调  handleVoiceAnimation处理音频播放动画回传 */
@property (nonatomic, copy) void (^sg_dictationVoiceDidClicked)(void (^handleVoiceAnimation)(BOOL isToStart));

/** 通过传入词汇显示键盘内容 */
@property (nonatomic, copy) NSString *vocabulary;

/** 默认是显示答案显示按钮，可以选择type显示语音播放按钮 */
@property (nonatomic, assign) SGDictationViewType viewType;

/** 更新答案显示视图的显示与隐藏 */
- (void)updateAnswerView:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
