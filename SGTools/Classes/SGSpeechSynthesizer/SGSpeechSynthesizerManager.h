//
//  SGSpeechSynthesizerManager.h
//  LGAfterschoolPlanFramework
//
//  Created by lg on 2019/7/15.
//  Copyright © 2019 lg. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define SGSpeechDefaultManager SGSpeechSynthesizerManager.defaultManager

typedef NS_ENUM(NSUInteger, SGSpeechSynthesizerRate) {
    SGSpeechSynthesizerRateDefault,
    SGSpeechSynthesizerRateMinimum,
    SGSpeechSynthesizerRateMaximum,
};

@interface SGSpeechSynthesizerManager : NSObject

+ (instancetype)defaultManager;

@property (nonatomic, assign) SGSpeechSynthesizerRate speechRate;

- (void)speechWithEnglishText:(NSString *)EnglishText completion:(void (^)(void))completion;

- (void)speechWithChineseText:(NSString *)ChineseText completion:(void (^)(void))completion;

- (void)cancelSpeech;

@end

NS_ASSUME_NONNULL_END
