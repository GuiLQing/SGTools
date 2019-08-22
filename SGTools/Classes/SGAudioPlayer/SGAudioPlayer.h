//
//  SGAudioPlayer.h
//  SGPlayerDemo
//
//  Created by 彭石桂 on 2019/5/25.
//  Copyright © 2019 GUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SGAudioPlayerDelegate <NSObject>

@optional

/** 音频准备就绪 */
- (void)audioPlayerReadyToPlay;
/** 音频解码发生错误 */
- (void)audioPlayerDecodeError;
/** 音频播放完成 */
- (void)audioPlayerDidPlayComplete;
/** 音频播放失败 */
- (void)audioPlayerDidPlayFailed;
/** 音频播放中断 */
- (void)audioPlayerBeginInterruption;
/** 音频播放结束中断 */
- (void)audioPlayerEndInterruption;
/** 音频下载成功 */
- (void)audioPlayerDownloadSuccessed;
/** 音频下载失败 */
- (void)audioPlayerdownloadFailed:(NSError *)error;
/** 音频当前播放时长、进度 */
- (void)audioPlayerCurrentPlaySeconds:(NSTimeInterval)seconds progress:(CGFloat)progress;
/** 需要缓冲 音频播放被中断 */
- (void)audioPlayerPlaybackBufferEmpty;
/** 缓存充足 音频播放开始播放 */
- (void)audioPlayerPlaybackLikelyToKeepUp;

@end

@interface SGAudioPlayer : NSObject

- (void)play;
- (void)pause;
- (void)stop;
- (void)invalidate;
- (void)audioSeekToMilliSeconds:(NSInteger)seconds;
- (void)audioSeekToMilliSeconds:(NSInteger)seconds completionHandler:(void (^)(BOOL finished))completionHandler;

@property (nonatomic, strong) NSString *audioUrl;

@property (nonatomic, weak) id<SGAudioPlayerDelegate> delegate;
/** 当前播放时间 */
@property (nonatomic, assign) NSTimeInterval currentPlayTime;
/** 音频总时长 */
@property (nonatomic, assign) NSTimeInterval totalDuration;
/** 播放速率 */
@property (nonatomic, assign) CGFloat audioRate;

@end

NS_ASSUME_NONNULL_END
