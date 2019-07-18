//
//  SGVocabularyAnswerView.m
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import "SGVocabularyAnswerView.h"
#import <Masonry/Masonry.h>
#import "UIImage+SGVocabularyResource.h"

#define SG_HexColor(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f]

@interface UIView (SGFrame)

@property (nonatomic, assign) CGSize sg_size;

- (void)sg_setPosition:(CGPoint)point atAnchorPoint:(CGPoint)anchorPoint;

@end

@implementation UIView (SGFrame)

- (CGSize)sg_size
{
    return self.frame.size;
}

- (void)setSg_size:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)sg_setPosition:(CGPoint)point atAnchorPoint:(CGPoint)anchorPoint
{
    CGFloat x = point.x - anchorPoint.x * CGRectGetWidth(self.bounds);
    CGFloat y = point.y - anchorPoint.y * CGRectGetHeight(self.bounds);
    CGRect frame = self.frame;
    frame.origin = CGPointMake(x, y);
    self.frame = frame;
}

@end

@interface SGVocabularyAnswerView ()

@property (nonatomic, strong) UIButton *lookAnswerBtn;
@property (nonatomic, strong) UILabel *answerLabel;
@property (nonatomic, strong) UIView *answerBackView;

@end

@implementation SGVocabularyAnswerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self layoutAnswerView];
    }
    return self;
}

- (void)layoutAnswerView {
    self.lookAnswerBtn = UIButton.alloc.init;
    [self.lookAnswerBtn setTitle:@"查看答案" forState:UIControlStateNormal];
    [self.lookAnswerBtn setTitle:@"查看答案" forState:UIControlStateSelected];
    [self.lookAnswerBtn setImage:[UIImage sg_imageNamed:@"sg_dictation_icon_lookAnswer_up"] forState:UIControlStateNormal];
    [self.lookAnswerBtn setImage:[UIImage sg_imageNamed:@"sg_dictation_icon_lookAnswer_down"] forState:UIControlStateSelected];
    self.lookAnswerBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.lookAnswerBtn setTitleColor:SG_HexColor(0x0baffb) forState:UIControlStateNormal];
    [self.lookAnswerBtn setTitleColor:SG_HexColor(0x0baffb) forState:UIControlStateSelected];
    
    CGFloat spacing = 5.0f;
    CGFloat imageHeight = self.lookAnswerBtn.imageView.image.size.height;
    CGFloat labelWidth = [self.lookAnswerBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0f]}].width;
    self.lookAnswerBtn.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + spacing/2, 0, -(labelWidth + spacing/2));
    self.lookAnswerBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageHeight + spacing/2), 0, imageHeight + spacing/2);
    
    [self.lookAnswerBtn addTarget:self action:@selector(lookAnswerAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.lookAnswerBtn];
    self.lookAnswerBtn.sg_size = [self.lookAnswerBtn sizeThatFits:CGSizeZero];
    [self.lookAnswerBtn sg_setPosition:CGPointMake(CGRectGetWidth(self.bounds) / 2, 10.0f) atAnchorPoint:CGPointMake(0.5, 0)];
    
    self.answerLabel = UILabel.alloc.init;
    self.answerLabel.font = [UIFont systemFontOfSize:14.0f];
    self.answerLabel.textAlignment = NSTextAlignmentCenter;
    self.answerLabel.numberOfLines = 0;
    self.answerLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:self.answerLabel];
    
    self.answerBackView = UIView.alloc.init;
    self.answerBackView.backgroundColor = SG_HexColor(0xf5f7f9);
    self.answerBackView.layer.cornerRadius = 8;
    [self insertSubview:self.answerBackView belowSubview:self.answerLabel];
    
    self.answerLabel.hidden = YES;
    self.answerBackView.hidden = YES;
}

- (void)setRightAnswer:(NSString *)answerString {
    _rightAnswer = answerString;
    
    self.answerLabel.text = answerString;
    
    CGSize answerLabelSize = [self.answerLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds) - 20.0f * 2, MAXFLOAT)];
    self.answerLabel.sg_size = CGSizeMake(answerLabelSize.width, answerLabelSize.height);
    [self.answerLabel sg_setPosition:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetMaxY(self.lookAnswerBtn.frame) + 20.0f) atAnchorPoint:CGPointMake(0.5, 0)];
    
    self.answerBackView.sg_size = CGSizeMake(answerLabelSize.width + 20.0f, answerLabelSize.height + 20.0f);
    self.answerBackView.center = self.answerLabel.center;
}

- (void)resetLookAnswerButton {
    self.lookAnswerBtn.selected = NO;
    self.answerLabel.hidden = YES;
    self.answerBackView.hidden = YES;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.hidden ? 0.0f : 30.0f);
    }];
}

- (void)lookAnswerAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo((sender.selected ? CGRectGetMaxY(self.answerBackView.frame) : CGRectGetMaxY(self.lookAnswerBtn.frame)) + 10.0f);
    }];
    self.answerLabel.hidden = !sender.selected;
    self.answerBackView.hidden = !sender.selected;
}

- (void)hideAnswerView {
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.0f);
    }];
    self.hidden = YES;
}

- (void)showAnswerView {
    self.hidden = NO;
    [self resetLookAnswerButton];
}

@end
