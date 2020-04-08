//
//  SGCountDownView.h
//  Masonry
//
//  Created by lancoo on 2020/4/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SGCountDownMode) {
    SGCountDownModeDefault,
    SGCountDownModeVoice,
    SGCountDownModeAnswer,
};

@interface SGCountDownView : UIView

@property (nonatomic, assign) SGCountDownMode sg_countDownMode;

- (void)sg_updateAudioProgress:(CGFloat)progress;

- (void)sg_updateAnswerProgress:(CGFloat)progress remaindSeconds:(NSTimeInterval)remaindSeconds;

@end

NS_ASSUME_NONNULL_END
