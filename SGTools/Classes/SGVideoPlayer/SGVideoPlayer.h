//
//  SGVideoPlayer.h
//  LGEnglishTrainingFramework
//
//  Created by lg on 2019/6/19.
//  Copyright © 2019 lg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SGVideoPlayerDelegate <NSObject>

@optional

/** 视频准备就绪 */
- (void)videoPlayerReadyToPlay;
/** 视频解码发生错误 */
- (void)videoPlayerDecodeError;
/** 视频播放完成 */
- (void)videoPlayerDidPlayComplete;
/** 视频播放失败 */
- (void)videoPlayerDidPlayFailed;
/** 视频播放中断 */
- (void)audioPlayerBeginInterruption;
/** 视频播放结束中断 */
- (void)audioPlayerEndInterruption;
/** 视频下载成功 */
- (void)videoPlayerDownloadSuccessed;
/** 视频下载失败 */
- (void)videoPlayerdownloadFailed:(NSError *)error;
/** 视频当前播放时长、进度 */
- (void)videoPlayerCurrentPlaySeconds:(NSTimeInterval)seconds progress:(CGFloat)progress;

@end

@interface SGVideoPlayer : NSObject

- (void)play;
- (void)pause;
- (void)stop;
- (void)invalidate;
- (void)videoSeekToMilliSeconds:(NSInteger)seconds;

@property (nonatomic, strong) NSString *vidoeUrl;

@property (nonatomic, weak) id<SGVideoPlayerDelegate> delegate;
/** 当前播放时间 */
@property (nonatomic, assign, readonly) NSTimeInterval currentPlayTime;
/** 视频总时长 */
@property (nonatomic, assign, readonly) NSTimeInterval totalDuration;
/** 播放速率 */
@property (nonatomic, assign) CGFloat videoRate;

@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;

@end

NS_ASSUME_NONNULL_END
