#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SGAudioPlayer.h"
#import "SGCollectionViewFlowLayout.h"
#import "SGGradientProgress.h"
#import "SGPickerView.h"
#import "SGAddressModel.h"
#import "SGAddressPickerView.h"
#import "SGBaseView.h"
#import "SGPickerViewMacro.h"
#import "NSDate+SGPickerView.h"
#import "SGDatePickerView.h"
#import "SGStringPickerView.h"
#import "SGSearchController.h"
#import "SGShadowView.h"
#import "SGSingleAudioPlayer.h"
#import "SGSpeechSynthesizerManager.h"
#import "SGTriangleView.h"
#import "SGVideoPlayer.h"
#import "SGVocabularyAnswerView.h"
#import "SGVocabularyDictationView.h"
#import "SGVocabularyKeyboardView.h"
#import "SGVocabularySpellingView.h"
#import "SGVocabularyTools.h"
#import "SGVocabularyVoiceView.h"
#import "UIImage+SGVocabularyResource.h"
#import "SGVoiceAnimationView.h"

FOUNDATION_EXPORT double SGToolsVersionNumber;
FOUNDATION_EXPORT const unsigned char SGToolsVersionString[];

