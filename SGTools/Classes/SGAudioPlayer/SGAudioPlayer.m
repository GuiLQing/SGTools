//
//  SGAudioPlayer.m
//  SGPlayerDemo
//
//  Created by 彭石桂 on 2019/5/25.
//  Copyright © 2019 GUI. All rights reserved.
//

#import "SGAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

#define SG_IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))
#define SG_PathCaches [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

static NSString * const kStatus                   = @"status";
static NSString * const kLoadedTimeRanges         = @"loadedTimeRanges";
static NSString * const kPlaybackBufferEmpty      = @"playbackBufferEmpty";
static NSString * const kPlaybackLikelyToKeepUp   = @"playbackLikelyToKeepUp";
static NSString * const kTimeControlStatus        = @"timeControlStatus";

@interface SGAudioPlayer ()

@property (nonatomic, strong) AVURLAsset *urlAsset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVQueuePlayer *audioPlayer;

@property (nonatomic, strong) id timeObserver;

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isDownload;

@end

@implementation SGAudioPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _audioRate = 1.0;
    }
    return self;
}

- (void)prepareToPlay {
    [self invalidate];
    
    NSURL *url = nil;
    if ([self.audioUrl hasPrefix:@"http"]) {
        url = [NSURL URLWithString:[self.audioUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        /** 判断本地有没有保存当前音频文件，如果有，将url换成本地的文件路径 */
        if ([NSFileManager.defaultManager fileExistsAtPath:self.downloadAudioPath]) {
            url = [NSURL fileURLWithPath:self.downloadAudioPath];
            _isDownload = YES;
        }
    } else {
        url = [NSURL fileURLWithPath:self.audioUrl];
    }
    
    _urlAsset = [AVURLAsset assetWithURL:url];
    _playerItem = [AVPlayerItem playerItemWithAsset:_urlAsset];
    _audioPlayer = [AVQueuePlayer playerWithPlayerItem:_playerItem];
    
    if (@available(iOS 10.0, *)) {
        _audioPlayer.automaticallyWaitsToMinimizeStalling = NO;
    }
    
    [self addNotification];
    [self addObserverWithPlayerItem:_playerItem];
}

- (void)play {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    [session setActive:YES error:nil];
    
    if (@available(iOS 10.0, *)) {
        [self.audioPlayer playImmediatelyAtRate:self.audioRate];
    } else {
        // Fallback on earlier versions
        [self.audioPlayer play];
        self.audioPlayer.rate = self.audioRate;
    }
    _isPlaying = YES;
}

- (void)pause {
    [self.audioPlayer pause];
    _isPlaying = NO;
}

- (void)stop {
    [_audioPlayer seekToTime:kCMTimeZero];
    [self pause];
}

- (void)invalidate {
    if (_isPlaying || _audioPlayer.rate > 0) [self stop];
    
    [self removeNotification];
    [self removeObserver:_playerItem];
    
    _audioPlayer = nil;
    _playerItem = nil;
    _urlAsset = nil;
}

- (void)audioSeekToMilliSeconds:(NSInteger)seconds {
    [self.audioPlayer seekToTime:CMTimeMake(seconds, 1000) toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000)];
}

- (void)audioSeekToMilliSeconds:(NSInteger)seconds completionHandler:(void (^)(BOOL finished))completionHandler {
    [self.audioPlayer seekToTime:CMTimeMake(seconds, 1000) toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000) completionHandler:^(BOOL finished) {
        if (completionHandler) completionHandler(finished);
    }];
}

- (void)setAudioUrl:(NSString *)audioUrl {
    _audioUrl = audioUrl;
    
    if (!SG_IsStrEmpty(audioUrl)) {
        [self prepareToPlay];
    }
}

- (void)setAudioRate:(CGFloat)audioRate {
    _audioRate = audioRate;
}

- (NSTimeInterval)currentPlayTime {
    return CMTimeGetSeconds(self.audioPlayer.currentTime);
}

- (NSTimeInterval)totalDuration {
    return CMTimeGetSeconds(self.audioPlayer.currentItem.duration);
}

#pragma mark - NSKVOObserver

- (void)addObserverWithPlayerItem:(AVPlayerItem *)playerItem {
    /** 监听AVPlayerItem状态 */
    [playerItem addObserver:self forKeyPath:kStatus options:NSKeyValueObservingOptionNew context:nil];
    /** loadedTimeRanges状态 */
    [playerItem addObserver:self forKeyPath:kLoadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
    /** 缓冲区空了，需要等待数据 */
    [playerItem addObserver:self forKeyPath:kPlaybackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
    /** playbackLikelyToKeepUp状态 */
    [playerItem addObserver:self forKeyPath:kPlaybackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
    
    [_audioPlayer addObserver:self forKeyPath:kTimeControlStatus options:NSKeyValueObservingOptionNew context:nil];
    
    /** 监听播放进度 */
    __weak typeof(self)weakSelf = self;
    _timeObserver = [_audioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:NULL usingBlock:^(CMTime time) {
        
        CGFloat totalSeconds = CMTimeGetSeconds(weakSelf.playerItem.duration);
        // 计算当前在第几秒
        CGFloat currentPlaySeconds = CMTimeGetSeconds(weakSelf.playerItem.currentTime);
        //进度 当前时间/总时间
        CGFloat currentPlayprogress = currentPlaySeconds / totalSeconds;
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(audioPlayerCurrentPlaySeconds:progress:)]) {
            [weakSelf.delegate audioPlayerCurrentPlaySeconds:currentPlaySeconds progress:currentPlayprogress];
        }
    }];
}

- (void)removeObserver:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:kStatus];
    [playerItem removeObserver:self forKeyPath:kLoadedTimeRanges];
    [playerItem removeObserver:self forKeyPath:kPlaybackBufferEmpty];
    [playerItem removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
    [playerItem cancelPendingSeeks];
    [playerItem.asset cancelLoading];
    
    [_audioPlayer removeObserver:self forKeyPath:kTimeControlStatus];
    
    [_audioPlayer removeTimeObserver:_timeObserver];
    _timeObserver = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kStatus]) {
        [self handleStatusObserver:object];
    } else if ([keyPath isEqualToString:kLoadedTimeRanges]) {
        [self handleLoadedTimeRangesObserver:object timeRanges:[change objectForKey:NSKeyValueChangeNewKey]];
    } else if ([keyPath isEqualToString:kPlaybackBufferEmpty]) {
        //缓冲区空了，所需做的处理操作
        NSLog(@"缓冲区空了 playbackBufferEmpty");
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerPlaybackBufferEmpty)]) {
            [self.delegate audioPlayerPlaybackBufferEmpty];
        }
    } else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp]) {
        //由于 AVPlayer 缓存不足就会自动暂停,所以缓存充足了需要手动播放,才能继续播放
        if (_isPlaying) [self play];
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerPlaybackLikelyToKeepUp)]) {
            [self.delegate audioPlayerPlaybackLikelyToKeepUp];
        }
    } else if ([keyPath isEqualToString:kTimeControlStatus]) {
        if (@available(iOS 10.0, *)) {
            NSLog(@"timeControlStatus: %@, reason: %@, rate: %@", @(_audioPlayer.timeControlStatus), _audioPlayer.reasonForWaitingToPlay, @(_audioPlayer.rate));
        } else {
            // Fallback on earlier versions
        }
    }
}

- (void)handleStatusObserver:(AVPlayerItem *)playerItem {
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) { //准备就绪
        //推荐将音视频播放放在这里
        NSLog(@"准备就绪");
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerReadyToPlay)]) {
            [self.delegate audioPlayerReadyToPlay];
        }
        if (_isDownload && self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerDownloadSuccessed)]) {
            [self.delegate audioPlayerDownloadSuccessed];
        }
        if (_isPlaying) [self play];
    } else {
        NSLog(@"解析错误, %@", playerItem.error);
        [self invalidate];
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerDecodeError)]) {
            [self.delegate audioPlayerDecodeError];
        }
    }
}

-  (void)handleLoadedTimeRangesObserver:(AVPlayerItem *)playerItem timeRanges:(NSArray *)timeRanges {
    if (timeRanges && [timeRanges count]) {
        // 获取缓冲区域
        CMTimeRange timerange = [[timeRanges firstObject] CMTimeRangeValue];
        // 计算缓冲总时间
        CMTime bufferDuration = CMTimeAdd(timerange.start, timerange.duration);
        // 获取到缓冲的时间,然后除以总时间,得到缓冲的进度
        NSTimeInterval currentBufferSeconds = CMTimeGetSeconds(bufferDuration);
        NSLog(@"缓冲的时间 %f", currentBufferSeconds);
        
        CGFloat bufferProgress = currentBufferSeconds / CMTimeGetSeconds(playerItem.duration);
        
        if (bufferProgress == 1.0f && !_isDownload) { /** 缓冲完成 */
            
            _isDownload = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerDownloadSuccessed)]) {
                [self.delegate audioPlayerDownloadSuccessed];
            }
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [weakSelf saveAudioAtPath:weakSelf.downloadAudioPath success:^{
                    weakSelf.isDownload = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(audioPlayerDownloadSuccessed)]) {
                            [weakSelf.delegate audioPlayerDownloadSuccessed];
                        }
                    });
                } failure:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(audioPlayerdownloadFailed:)]) {
                            [weakSelf.delegate audioPlayerdownloadFailed:error];
                        }
                    });
                }];
            });
        }
    }
}

#pragma mark - NSNotificationAction

- (void)addNotification {
    /** 播放完成 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    /** 播放失败 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayDidFailed:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    /** 声音被打断的通知（电话打来） */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    //耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    /** 进入后台 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    /** 返回前台 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/** 播放完成 */
- (void)audioPlayDidEnd:(NSNotification *)notification {
    [self stop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerDidPlayComplete)]) {
        [self.delegate audioPlayerDidPlayComplete];
    }
}

/** 播放失败 */
- (void)audioPlayDidFailed:(NSNotification *)notification {
    [self stop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerDidPlayFailed)]) {
        [self.delegate audioPlayerDidPlayFailed];
    }
}

//中断事件
- (void)handleInterruption:(NSNotification *)notification{
    NSDictionary *info = notification.userInfo;
    //一个中断状态类型
    AVAudioSessionInterruptionType type =[info[AVAudioSessionInterruptionTypeKey] integerValue];
    //判断开始中断还是中断已经结束
    if (type == AVAudioSessionInterruptionTypeBegan) {
        //停止播放
        [self.audioPlayer pause];
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerBeginInterruption)]) {
            [self.delegate audioPlayerBeginInterruption];
        }
    }else {
        //如果中断结束会附带一个KEY值，表明是否应该恢复音频
        AVAudioSessionInterruptionOptions options =[info[AVAudioSessionInterruptionOptionKey] integerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            //恢复播放
//            if (_isPlaying) [self play];
            if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerEndInterruption)]) {
                [self.delegate audioPlayerEndInterruption];
            }
        }
    }
}

//耳机插入、拔出事件
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            //判断为耳机接口
            AVAudioSessionRouteDescription *previousRoute =interuptionDict[AVAudioSessionRouteChangePreviousRouteKey];
            AVAudioSessionPortDescription *previousOutput =previousRoute.outputs[0];
            NSString *portType =previousOutput.portType;
            if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
                // 拔掉耳机继续播放
                if (_isPlaying) [self play];
            }
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            break;
    }
}

- (void)willResignActive:(NSNotification*)notification {
    [self.audioPlayer pause];
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerBeginInterruption)]) {
        [self.delegate audioPlayerBeginInterruption];
    }
}

- (void)didBecomeActive:(NSNotification*)notification {
//    if (_isPlaying) [self play];
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerEndInterruption)]) {
        [self.delegate audioPlayerEndInterruption];
    }
}

#pragma mark - downloadAudio

- (NSString *)downloadAudioPath {
    if (SG_IsStrEmpty(_audioUrl)) return nil;
    NSString *downloadAudioPath = [SG_PathCaches stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [_audioUrl stringByReplacingOccurrencesOfString:@"/" withString:@"-"]]];
    return downloadAudioPath;
}

- (void)saveAudioAtPath:(NSString *)savePath success:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
    NSLog(@"savePath ... %@", savePath);
    if (SG_IsStrEmpty(savePath)) {
        failure(nil);
        return ;
    }
    if ([NSFileManager.defaultManager fileExistsAtPath:savePath]) {
        success();
        return ;
    }
    
    AVAsset *movieURLAsset = self.playerItem.asset;
    AVAssetTrack *audioAssetTrack = [movieURLAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    NSError *error = nil;
    
//    AVAssetTrack *videoAssetTrack = [movieURLAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
//    AVMutableCompositionTrack *videoCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, movieURLAsset.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:&error];
//    if (error) {
//        NSLog(@"error is %@", error);
//    }
    
    AVMutableCompositionTrack *audioCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    error = nil;
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, movieURLAsset.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:&error];
    if (error) {
        NSLog(@"error is %@", error);
    }
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetPassthrough];
    
    
    exporter.outputURL = [NSURL fileURLWithPath:savePath];
    exporter.outputFileType = AVFileTypeWAVE;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if( exporter.status == AVAssetExportSessionStatusCompleted){
            NSLog(@"保存成功");
            success();
        }else if( exporter.status == AVAssetExportSessionStatusFailed ){
            NSLog(@"保存失败 ... %@", exporter.error);
            failure(exporter.error);
        }
    }];
}

@end
