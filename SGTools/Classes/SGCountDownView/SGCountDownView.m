//
//  SGCountDownView.m
//  Masonry
//
//  Created by lancoo on 2020/4/8.
//

#import "SGCountDownView.h"
#import "SGCircularProgress.h"

static inline UIColor * _Nullable SGCountDownHexColor(NSInteger c) {
    return [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f];
}

@interface SGCountDownView ()

@property (nonatomic, strong) UIImageView *audioProgressIV;

@property (nonatomic, strong) SGCircularProgress *audioProgressView;

@property (nonatomic, strong) SGCircularProgress *answerProgressBackView;

@property (nonatomic, strong) SGCircularProgress *answerProgressView;

@property (nonatomic, strong) UILabel *secondsLabel;

@property (nonatomic, strong) NSBundle *boundle;

@end

@implementation SGCountDownView

- (UIImage * (^)(NSString *imageName))sg_countDownImage {
    return ^(NSString *imageName) {
        if (!self.boundle) {
            self.boundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:SGCountDownView.class] pathForResource:@"SGCountDownView" ofType:@"bundle"]];
        }
        return [UIImage imageNamed:[self.boundle.resourcePath stringByAppendingPathComponent:imageName]];
    };
}

- (void)layoutUI {
    self.audioProgressIV = UIImageView.alloc.init;
    self.audioProgressIV.frame = (CGRect){self.audioProgressIV.frame.origin, CGSizeMake(CGRectGetWidth(self.bounds) + 20.0f, CGRectGetHeight(self.bounds) + 20.0f)};
    self.audioProgressIV.center = self.center;
    self.audioProgressIV.image = self.sg_countDownImage(@"sg_countDown_icon_play_default");
    self.audioProgressIV.animationImages = @[
                                         self.sg_countDownImage(@"sg_countDown_icon_playGif_1"),
                                         self.sg_countDownImage(@"sg_countDown_icon_playGif_2"),
                                         self.sg_countDownImage(@"sg_countDown_icon_playGif_3"),
                                         ];
    self.audioProgressIV.animationDuration = 0.5;
    
    [self addSubview:self.audioProgressIV];
    
    [self addSubview:self.audioProgressView];

    [self addSubview:self.answerProgressBackView];
    
    [self addSubview:self.answerProgressView];
    
    [self addSubview:self.secondsLabel];
}

- (void)setSg_countDownMode:(SGCountDownMode)sg_countDownMode {
    _sg_countDownMode = sg_countDownMode;
    
    self.audioProgressIV.hidden = YES;
    self.audioProgressView.hidden = YES;
    self.answerProgressBackView.hidden = YES;
    self.answerProgressView.hidden = YES;
    self.secondsLabel.hidden = YES;
    [self.audioProgressIV stopAnimating];
    
    switch (sg_countDownMode) {
        case SGCountDownModeDefault: {
            self.audioProgressIV.hidden = NO;
        }
            break;
        case SGCountDownModeVoice: {
            self.audioProgressIV.hidden = NO;
            self.audioProgressView.hidden = NO;
            [self.audioProgressIV startAnimating];
        }
            break;
        case SGCountDownModeAnswer: {
            self.answerProgressBackView.hidden = NO;
            self.answerProgressView.hidden = NO;
            self.secondsLabel.hidden = NO;
        }
            break;
    }
}

- (void)sg_updateAudioProgress:(CGFloat)progress {
    self.audioProgressView.progress = progress;
}

- (void)sg_updateAnswerProgress:(CGFloat)progress remaindSeconds:(NSTimeInterval)remaindSeconds {
    self.answerProgressView.progress = progress;
    self.secondsLabel.text = [NSString stringWithFormat:@"%zd", (NSInteger)ceil(remaindSeconds)];
}

#pragma mark - lazyLoading

- (SGCircularProgress *)audioProgressView {
    if (!_audioProgressView) {
        _audioProgressView = [[SGCircularProgress alloc] initWithFrame:self.bounds];
        _audioProgressView.roundedCorners = YES;
        
        _audioProgressView.trackTintColor = UIColor.clearColor;
        _audioProgressView.progressTintColor = SGCountDownHexColor(0x0a8fa);
        _audioProgressView.innerTintColor = UIColor.clearColor;
        _audioProgressView.thicknessRatio = 0.09;
    }
    return _audioProgressView;
}

- (SGCircularProgress *)answerProgressView {
    if (!_answerProgressView) {
        _answerProgressView = [[SGCircularProgress alloc] initWithFrame:self.bounds];
        _answerProgressView.roundedCorners = YES;
        
        _answerProgressView.trackTintColor = UIColor.clearColor;
        _answerProgressView.progressTintColor = SGCountDownHexColor(0xf5f7f9);
        _answerProgressView.innerTintColor = UIColor.clearColor;
        _answerProgressView.thicknessRatio = 0.09;
    }
    return _answerProgressView;
}

- (SGCircularProgress *)answerProgressBackView {
    if (!_answerProgressBackView) {
        _answerProgressBackView = [[SGCircularProgress alloc] initWithFrame:self.bounds];
        _answerProgressBackView.roundedCorners = YES;
        
        _answerProgressBackView.trackTintColor = SGCountDownHexColor(0x0c2f6);
        _answerProgressBackView.progressTintColor = SGCountDownHexColor(0x0e5cc);
        _answerProgressBackView.innerTintColor = UIColor.clearColor;
        _answerProgressBackView.thicknessRatio = 0.09;
        _answerProgressBackView.progress = 1;
    }
    return _answerProgressBackView;
}

- (UILabel *)secondsLabel {
    if (!_secondsLabel) {
        _secondsLabel = UILabel.alloc.init;
        _secondsLabel.frame = self.bounds;
        _secondsLabel.textColor = SGCountDownHexColor(0x0c2f6);
        _secondsLabel.font = [UIFont systemFontOfSize:30.0f];
        _secondsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _secondsLabel;
}

@end