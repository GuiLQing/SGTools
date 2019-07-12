//
//  SGVoiceAnimationView.m
//  ETVoiceAnimationDemo
//
//  Created by lg on 2019/6/27.
//  Copyright © 2019 lg. All rights reserved.
//

#import "SGVoiceAnimationView.h"

static NSInteger const SGVoiceLineCount = 7;
static CGFloat const SGVoiceLineWidth = 5.0f;

@interface SGVoiceAnimationView ()

@property (nonatomic, strong) NSMutableArray *sounds;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) CGFloat currentSound;

@property (nonatomic, assign) NSInteger displayLinkCounter;

@end

@implementation SGVoiceAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
        [_displayLink addToRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
        
        [self resetSounds];
    }
    return self;
}

- (void)updateSound:(CGFloat)sound {
    _currentSound = sound;
}

- (void)resetSounds {
    _sounds = [NSMutableArray array];
    for (NSInteger i = 0; i < SGVoiceLineCount; i ++) {
        [_sounds addObject:@(0)];
    }
}

- (void)startAnimation {
    _displayLink.paused = NO;
}

- (void)stopAnimation {
    _displayLink.paused = YES;
    [self resetSounds];
    [self setNeedsDisplay];
}

- (void)displayLinkAction {
    _displayLinkCounter ++;
    
    if (_displayLinkCounter % 5 == 0) {
        [self.sounds removeObjectAtIndex:0];
        [self.sounds addObject:@(self.currentSound)];
        self.currentSound = 0;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    [UIColor.whiteColor setFill];
    CGContextFillRect(context, rect);
    
    CGContextSetRGBFillColor(context, 0.0f, 200/255.0f, 195/255.0f, 1.0f);
    CGContextSetLineWidth(context, SGVoiceLineWidth);
    
    /** 0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 0 */
    NSMutableArray *sounds = [NSMutableArray array];
    [sounds addObjectsFromArray:self.sounds];
    [sounds removeLastObject];
    [sounds addObjectsFromArray:self.sounds.reverseObjectEnumerator.allObjects];
    
    CGFloat space = (CGRectGetWidth(self.bounds) - sounds.count * SGVoiceLineWidth) / (sounds.count + 1);
    for (NSInteger i = 0; i < sounds.count; i ++) {
        CGFloat sound = [sounds[i] doubleValue];
        CGFloat lineHeight = MAX(5, sound * CGRectGetHeight(self.bounds));
        CGFloat lineX = space + (space + SGVoiceLineWidth) * i;
        CGFloat lineY = (CGRectGetHeight(self.bounds) - lineHeight) / 2;
        CGRect rect = CGRectMake(lineX, lineY, SGVoiceLineWidth, lineHeight);
        CGContextFillRect(context, rect);
    }
}

@end
