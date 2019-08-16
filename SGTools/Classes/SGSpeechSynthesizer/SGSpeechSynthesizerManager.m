//
//  SGSpeechSynthesizerManager.m
//  LGAfterschoolPlanFramework
//
//  Created by lg on 2019/7/15.
//  Copyright © 2019 lg. All rights reserved.
//

#import "SGSpeechSynthesizerManager.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, SGSpeechLanguageType) {
    SGSpeechLanguageTypeEnglish,
    SGSpeechLanguageTypeChinese,
};

@interface SGSpeechSynthesizerManager () <AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

@property (nonatomic, strong) AVSpeechUtterance *utterance;

@property (nonatomic, copy) void (^speechDidCompletion)(void);

@end

@implementation SGSpeechSynthesizerManager

+ (instancetype)defaultManager {
    static SGSpeechSynthesizerManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = SGSpeechSynthesizerManager.alloc.init;
        _manager.speechRate = SGSpeechSynthesizerRateDefault;
    });
    return _manager;
}

- (void)speechWithEnglishText:(NSString *)EnglishText completion:(void (^)(void))completion {
    [self speechWithText:EnglishText languageType:SGSpeechLanguageTypeEnglish completion:completion];
}

- (void)speechWithChineseText:(NSString *)ChineseText completion:(void (^)(void))completion {
    [self speechWithText:ChineseText languageType:SGSpeechLanguageTypeChinese completion:completion];
}

- (void)speechWithText:(NSString *)text languageType:(SGSpeechLanguageType)languageType completion:(void (^)(void))completion {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    [session setActive:YES error:nil];
    
    /** 创建语音合成的文本 */
    _utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    _utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.language(languageType)];
    /** 播放速率 */
    _utterance.rate = [@{
                         @(SGSpeechSynthesizerRateDefault) : @(AVSpeechUtteranceDefaultSpeechRate),
                         @(SGSpeechSynthesizerRateMinimum) : @(AVSpeechUtteranceMinimumSpeechRate),
                         @(SGSpeechSynthesizerRateMaximum) : @(AVSpeechUtteranceMaximumSpeechRate),
                         }[@(_speechRate)] doubleValue];
    /** 改变音调 */
    _utterance.pitchMultiplier = 1.0f;
    /** 运用合成器 */
    _synthesizer = [[AVSpeechSynthesizer alloc] init];
    _synthesizer.delegate = self;
    /** 变成音频输出 */
    [_synthesizer speakUtterance:_utterance];
    
    self.speechDidCompletion = ^{
        completion();
    };
}

- (void)cancelSpeech {
    if (_synthesizer) {
        [_synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    _synthesizer = nil;
    _utterance = nil;
}

- (NSString * (^)(SGSpeechLanguageType languageType))language {
    return ^(SGSpeechLanguageType languageType) {
        switch (languageType) {
            case SGSpeechLanguageTypeEnglish:
                return @"en-GB"; /** en-GB:男声 en-US:女声 */
            case SGSpeechLanguageTypeChinese:
                return @"zh-CN";
        }
    };
}

/**
 AVSpeechBoundaryImmediate, //立刻停止
 AVSpeechBoundaryWord // 读完最后一个字停止
 */

/**
 // 添加 播放话语 到 播放语音 队列, 可以设置utterance的属性来控制播放
 - (void)speakUtterance:(AVSpeechUtterance *)utterance;
 
 对于 stopSpeakingAtBoundary: 语音单元的操作, 如果中断, 会清空队列
 // 中断
 - (BOOL)stopSpeakingAtBoundary:(AVSpeechBoundary)boundary;
 // 暂停
 - (BOOL)pauseSpeakingAtBoundary:(AVSpeechBoundary)boundary;
 // 继续
 - (BOOL)continueSpeaking;
 */

/**
 // 设置使用哪一个国家的语言播放
 @property(nonatomic, retain, nullable) AVSpeechSynthesisVoice *voice;
 // 获取当前需要播放的文字, 只读属性
 @property(nonatomic, readonly) NSString *speechString;
 // 获取当前需要播放的文字 - 富文本, 只读属性, iOS10以后可用
 @property(nonatomic, readonly) NSAttributedString *attributedSpeechString;
 // 本段文字播放时的 语速, 应介于AVSpeechUtteranceMinimumSpeechRate 和 AVSpeechUtteranceMaximumSpeechRate 之间
 @property(nonatomic) float rate;
 // 在播放特定语句时改变声音的声调, 一般取值介于0.5(底音调)~2.0(高音调)之间
 @property(nonatomic) float pitchMultiplier;
 // 声音大小, 0.0 ~ 1.0 之间
 @property(nonatomic) float volume;
 // 播放后的延迟, 就是本次文字播放完之后的停顿时间, 默认是0
 @property(nonatomic) NSTimeInterval preUtteranceDelay;
 // 播放前的延迟, 就是本次文字播放前停顿的时间, 然后播放本段文字, 默认是0
 @property(nonatomic) NSTimeInterval postUtteranceDelay;
 */

#pragma mark - AVSpeechSynthesizerDelegate

// 开始播放 语音单元
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    
}

// 完成播放 语音单元
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    if (self.speechDidCompletion) {
        self.speechDidCompletion();
    }
}

// 暂停播放 语音单元
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance {
    
}

// 继续播放 语音单元
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance {
    
}

// 取消播放 语音单元
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    
}

// 这里 指的是 又来监听 播放 字符范围
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
    
}

/**
 ar-SA  沙特阿拉伯（阿拉伯文）
 
 en-ZA, 南非（英文）
 
 nl-BE, 比利时（荷兰文）
 
 en-AU, 澳大利亚（英文）
 
 th-TH, 泰国（泰文）
 
 de-DE, 德国（德文）
 
 en-US, 美国（英文）
 
 pt-BR, 巴西（葡萄牙文）
 
 pl-PL, 波兰（波兰文）
 
 en-IE, 爱尔兰（英文）
 
 el-GR, 希腊（希腊文）
 
 id-ID, 印度尼西亚（印度尼西亚文）
 
 sv-SE, 瑞典（瑞典文）
 
 tr-TR, 土耳其（土耳其文）
 
 pt-PT, 葡萄牙（葡萄牙文）
 
 ja-JP, 日本（日文）
 
 ko-KR, 南朝鲜（朝鲜文）
 
 hu-HU, 匈牙利（匈牙利文）
 
 cs-CZ, 捷克共和国（捷克文）
 
 da-DK, 丹麦（丹麦文）
 
 es-MX, 墨西哥（西班牙文）
 
 fr-CA, 加拿大（法文）
 
 nl-NL, 荷兰（荷兰文）
 
 fi-FI, 芬兰（芬兰文）
 
 es-ES, 西班牙（西班牙文）
 
 it-IT, 意大利（意大利文）
 
 he-IL, 以色列（希伯莱文，阿拉伯文）
 
 no-NO, 挪威（挪威文）
 
 ro-RO, 罗马尼亚（罗马尼亚文）
 
 zh-HK, 香港（中文）
 
 zh-TW, 台湾（中文）
 
 sk-SK, 斯洛伐克（斯洛伐克文）
 
 zh-CN, 中国（中文）
 
 ru-RU, 俄罗斯（俄文）
 
 en-GB, 英国（英文）
 
 fr-FR, 法国（法文）
 
 hi-IN  印度（印度文）
 */

@end
