//
//  SGSingleAudioPlayer.m
//  LGEnglishTrainingFramework
//
//  Created by lg on 2019/6/14.
//  Copyright © 2019 lg. All rights reserved.
//

#import "SGSingleAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

static NSString * const SGStatus                   = @"status";
static NSString * const SGLoadedTimeRanges         = @"loadedTimeRanges";
static NSString * const SGPlaybackBufferEmpty      = @"playbackBufferEmpty";
static NSString * const SGPlaybackLikelyToKeepUp   = @"playbackLikelyToKeepUp";
static NSString * const SGTimeControlStatus        = @"timeControlStatus";

@interface SGSingleAudioPlayer ()

@property (nonatomic, strong) AVURLAsset *urlAsset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVQueuePlayer *audioPlayer;

@property (nonatomic, strong) id timeObserver;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) NSURL *audioUrl;

@property (nonatomic, assign) CGFloat audioRate;

@property (nonatomic, strong) void (^completion)(void);
@property (nonatomic, strong) void (^failure)(NSError *error);
@property (nonatomic, strong) void (^playProgress)(CGFloat progress, NSTimeInterval audioDuration, NSTimeInterval playSenconds);

@end

@implementation SGSingleAudioPlayer

+ (instancetype)audioPlayWithUrl:(NSURL *)url playProgress:(void (^)(CGFloat progress, NSTimeInterval audioDuration, NSTimeInterval playSenconds))playProgress completionHandle:(void (^)(NSError * __nullable error))completionHandle {
    return [self audioPlayWithUrl:url audioRate:1.0 playProgress:playProgress completionHandle:completionHandle];
}

+ (instancetype)audioPlayWithUrl:(NSURL *)url audioRate:(CGFloat)audioRate playProgress:(void (^)(CGFloat progress, NSTimeInterval audioDuration, NSTimeInterval playSenconds))playProgress completionHandle:(void (^)(NSError * __nullable error))completionHandle {
    if (!url) {
        if (completionHandle) {
            completionHandle([NSError errorWithDomain:SGSingleAudioLocalErrorDamain code:0 userInfo:@{NSLocalizedDescriptionKey : @"URL错误"}]);
        }
        return nil;
    }
    SGSingleAudioPlayer *player = [SGSingleAudioPlayer sharedPlayer];
    player.audioRate = audioRate;
    player.audioUrl = url;
    player.failure = ^(NSError *error) {
        if (completionHandle) {
            completionHandle(error);
        }
    };
    player.completion = ^{
        if (completionHandle) {
            completionHandle(nil);
        }
    };
    player.playProgress = ^(CGFloat progress, NSTimeInterval audioDuration, NSTimeInterval playSenconds) {
        if (playProgress) {
            playProgress(progress, audioDuration, playSenconds);
        }
    };
    [player play];
    return player;
}

+ (instancetype)sharedPlayer {
    static SGSingleAudioPlayer *_singleAudioPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleAudioPlayer = [[SGSingleAudioPlayer alloc] init];
        _singleAudioPlayer.audioRate = 1.0;
    });
    return _singleAudioPlayer;
}

- (void)setAudioUrl:(NSURL *)audioUrl {
    _audioUrl = audioUrl;
    
    [self invalidate];
    
    _urlAsset = [AVURLAsset assetWithURL:_audioUrl];
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
    
    [self.audioPlayer play];
    self.audioPlayer.rate = self.audioRate;
    _isPlaying = YES;
}

- (void)pause {
    [self.audioPlayer pause];
    _isPlaying = NO;
}

- (void)invalidate {
    if (_isPlaying || _audioPlayer.rate > 0) [self pause];
    
    [self removeNotification];
    [self removeObserver:_playerItem];
    
    _audioPlayer = nil;
    _playerItem = nil;
    _urlAsset = nil;
}

#pragma mark - NSKVOObserver

- (void)addObserverWithPlayerItem:(AVPlayerItem *)playerItem {
    /** 监听AVPlayerItem状态 */
    [playerItem addObserver:self forKeyPath:SGStatus options:NSKeyValueObservingOptionNew context:nil];
    /** loadedTimeRanges状态 */
    [playerItem addObserver:self forKeyPath:SGLoadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
    /** 缓冲区空了，需要等待数据 */
    [playerItem addObserver:self forKeyPath:SGPlaybackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
    /** playbackLikelyToKeepUp状态 */
    [playerItem addObserver:self forKeyPath:SGPlaybackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
    
    [_audioPlayer addObserver:self forKeyPath:SGTimeControlStatus options:NSKeyValueObservingOptionNew context:nil];
    
    /** 监听播放进度 */
    __weak typeof(self)weakSelf = self;
    _timeObserver = [_audioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:NULL usingBlock:^(CMTime time) {
        
        CGFloat totalSeconds = CMTimeGetSeconds(weakSelf.playerItem.duration);
        // 计算当前在第几秒
        CGFloat currentPlaySeconds = CMTimeGetSeconds(weakSelf.playerItem.currentTime);
        //进度 当前时间/总时间
        CGFloat currentPlayprogress = currentPlaySeconds / totalSeconds;
        NSLog(@"%lf", currentPlayprogress);
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.playProgress) {
            strongSelf.playProgress(currentPlayprogress, totalSeconds, currentPlaySeconds);
        }
    }];
}

- (void)removeObserver:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:SGStatus];
    [playerItem removeObserver:self forKeyPath:SGLoadedTimeRanges];
    [playerItem removeObserver:self forKeyPath:SGPlaybackBufferEmpty];
    [playerItem removeObserver:self forKeyPath:SGPlaybackLikelyToKeepUp];
    [playerItem cancelPendingSeeks];
    [playerItem.asset cancelLoading];
    
    [_audioPlayer removeObserver:self forKeyPath:SGTimeControlStatus];
    
    [_audioPlayer removeTimeObserver:_timeObserver];
    _timeObserver = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:SGStatus]) {
        [self handleStatusObserver:object];
    } else if ([keyPath isEqualToString:SGLoadedTimeRanges]) {
        [self handleLoadedTimeRangesObserver:object timeRanges:[change objectForKey:NSKeyValueChangeNewKey]];
    } else if ([keyPath isEqualToString:SGPlaybackBufferEmpty]) {
        //缓冲区空了，所需做的处理操作
        NSLog(@"缓冲区空了 playbackBufferEmpty");
    } else if ([keyPath isEqualToString:SGPlaybackLikelyToKeepUp]) {
        //由于 AVPlayer 缓存不足就会自动暂停,所以缓存充足了需要手动播放,才能继续播放
        if (_isPlaying) [self play];
    } else if ([keyPath isEqualToString:SGTimeControlStatus]) {
        NSLog(@"timeControlStatus: %@, reason: %@, rate: %@", @(_audioPlayer.timeControlStatus), _audioPlayer.reasonForWaitingToPlay, @(_audioPlayer.rate));
    }
}

- (void)handleStatusObserver:(AVPlayerItem *)playerItem {
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) { //准备就绪
        //推荐将音视频播放放在这里
        NSLog(@"准备就绪");
        if (_isPlaying) [self play];
    } else {
        NSLog(@"解析错误, %@", playerItem.error);
        [self invalidate];
        if (self.failure) {
            self.failure([NSError errorWithDomain:SGSingleAudioLocalErrorDamain code:0 userInfo:@{NSLocalizedDescriptionKey : @"音频解析错误"}]);
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
        
        NSTimeInterval totalDuration = CMTimeGetSeconds(playerItem.duration);
        
        CGFloat bufferProgress = currentBufferSeconds / totalDuration;
        
        NSLog(@"%lf", bufferProgress);
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
    [self invalidate];
    if (self.completion) {
        self.completion();
    }
}

/** 播放失败 */
- (void)audioPlayDidFailed:(NSNotification *)notification {
    [self invalidate];
    if (self.failure) {
        self.failure([NSError errorWithDomain:SGSingleAudioLocalErrorDamain code:0 userInfo:@{NSLocalizedDescriptionKey : @"音频播放失败"}]);
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
    }else {
        //如果中断结束会附带一个KEY值，表明是否应该恢复音频
        AVAudioSessionInterruptionOptions options =[info[AVAudioSessionInterruptionOptionKey] integerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            //恢复播放
//            if (_isPlaying) [self play];
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
}

- (void)didBecomeActive:(NSNotification*)notification {
//    if (_isPlaying) [self play];
}

@end
