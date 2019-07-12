//
//  SGVoiceAnimationView.h
//  ETVoiceAnimationDemo
//
//  Created by lg on 2019/6/27.
//  Copyright © 2019 lg. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGVoiceAnimationView : UIView

- (void)startAnimation;

- (void)stopAnimation;

/** 传入0-1的浮点数 */
- (void)updateSound:(CGFloat)sound;

@end

NS_ASSUME_NONNULL_END
