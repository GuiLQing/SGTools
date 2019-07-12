//
//  SGSingleAudioPlayer.h
//  LGEnglishTrainingFramework
//
//  Created by lg on 2019/6/14.
//  Copyright © 2019 lg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const SGSingleAudioLocalErrorDamain = @"SGSingleAudioLocalErrorDamain";

@interface SGSingleAudioPlayer : NSObject

+ (instancetype)audioPlayWithUrl:(NSURL *)url playProgress:(void (^ _Nullable )(CGFloat progress, NSTimeInterval audioDuration, NSTimeInterval playSenconds))playProgress completionHandle:(void  (^ _Nullable )(NSError * __nullable error))completionHandle;

- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
