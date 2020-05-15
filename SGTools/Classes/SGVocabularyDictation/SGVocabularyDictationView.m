//
//  SGVocabularyDictationView.m
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import "SGVocabularyDictationView.h"
#import <Masonry/Masonry.h>
#import "SGVocabularyTools.h"
#import "SGVocabularySpellingView.h"
#import "SGVocabularyAnswerView.h"
#import "SGVocabularyVoiceView.h"
#import "SGVocabularyKeyboardView.h"

@interface SGVocabularyDictationView () <SGVocabularyKeyboardViewDelegate, SGVocabularySpellingViewDelegate>

@property (nonatomic, strong) SGVocabularySpellingView *spellingView;

@property (nonatomic, strong) SGVocabularyAnswerView *answerView;

@property (nonatomic, strong) SGVocabularyVoiceView *voiceView;

@property (nonatomic, strong) SGVocabularyKeyboardView *keyboardView;

@end

@implementation SGVocabularyDictationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI {
    CGSize spellingViewSize = CGSizeMake(CGRectGetWidth(self.bounds) - 20.0f * 2, 50.0f);
    self.spellingView = [[SGVocabularySpellingView alloc] initWithFrame:(CGRect){CGPointMake(20.0, 20.0f), spellingViewSize}];
    self.spellingView.delegate = self;
    [self addSubview:self.spellingView];
    [self.spellingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(spellingViewSize);
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).offset(20.0f);
    }];
    
    CGSize answerViewSize = CGSizeMake(CGRectGetWidth(self.bounds) - 20.0f * 2, 30.0f);
    self.answerView = [[SGVocabularyAnswerView alloc] initWithFrame:(CGRect){CGPointMake(20.0f, CGRectGetMaxY(self.spellingView.frame) + 10.0f), answerViewSize}];
    [self addSubview:self.answerView];
    [self.answerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.spellingView.mas_bottom).offset(10.0f);
        make.size.mas_equalTo(answerViewSize);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    self.voiceView = SGVocabularyVoiceView.alloc.init;
    self.voiceView.hidden = NO;
    [self addSubview:self.voiceView];
    [self.voiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.answerView);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    CGSize keyboardViewSize = CGSizeMake(CGRectGetWidth(self.bounds) - 20.0f * 2, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 220.0f : 175.0f);
    self.keyboardView = [[SGVocabularyKeyboardView alloc] initWithFrame:(CGRect){CGPointMake(20.0f, CGRectGetMaxY(self.answerView.frame) + 10.0f), keyboardViewSize}];
    self.keyboardView.delegate = self;
    [self addSubview:self.keyboardView];
    [self.keyboardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(keyboardViewSize);
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.answerView.mas_bottom).offset(10.0f);
        make.bottom.equalTo(self.mas_bottom).offset(-20.0f);
    }];
    
    __weak typeof(self) weakSelf = self;
    self.voiceView.voiceImageDidClicked = ^(void (^ _Nonnull handleVoiceAnimation)(BOOL)) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.sg_dictationVoiceDidClicked) strongSelf.sg_dictationVoiceDidClicked(handleVoiceAnimation);
    };
}

- (void)setVocabulary:(NSString *)vocabulary {
    NSArray<NSArray *> *rightVocabularys = [SGVocabularyTools cutArrayByVocabulary:vocabulary];
    self.spellingView.rightVocabularys = rightVocabularys;
    
    self.answerView.rightAnswer = vocabulary;
    
    if (!self.defaultKeyBoards || self.defaultKeyBoards.count == 0) {
        NSMutableArray *results = [NSMutableArray array];
        for (NSArray *array in rightVocabularys) {
            [results addObjectsFromArray:array];
        }
        self.keyboardView.randomVocabularys = [SGVocabularyTools addRandomSortResults:results length:[SGVocabularyTools cutLengthByVocabulary:vocabulary]];
        if (self.sg_updateDefaultKeyBoards) {
            self.sg_updateDefaultKeyBoards(self.keyboardView.randomVocabularys);
        }
    } else {
        self.keyboardView.randomVocabularys = self.defaultKeyBoards;
        self.keyboardView.selectedKeyBoards = self.selectedKeyBoards;
        for (NSString *text in self.selectedKeyBoards) {
            [self.spellingView addSpellingAnswer:text];
        }
    }
    
    [self.answerView resetLookAnswerButton];
}

- (void)setViewType:(SGDictationViewType)viewType {
    _viewType = viewType;
    
    [self.answerView resetLookAnswerButton];
    
    self.answerView.hidden = YES;
    self.voiceView.hidden = YES;
    
    switch (viewType) {
        case SGDictationViewTypeAnswer: {
            self.answerView.hidden = NO;
            [self.keyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.answerView.mas_bottom).offset(10.0f);
            }];
        }
            break;
        case SGDictationViewTypeVoice: {
            self.voiceView.hidden = NO;
            [self.keyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.answerView.mas_bottom).offset(10.0f);
            }];
        }
            break;
        case SGDictationViewTypeNone: {
            [self.keyboardView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.spellingView.mas_bottom).offset(20.0f);
            }];
        }
            break;
    }
}

- (void)updateAnswerView:(BOOL)isHidden {
    if (self.viewType != SGDictationViewTypeAnswer) return;
    
    if (isHidden) {
        [self.answerView hideAnswerView];
    } else {
        [self.answerView showAnswerView];
    }
}

#pragma mark - ETLTVocabularySpellingViewDelegate

- (void)sg_spellingViewDeleteDidClickedWithWords:(NSString *)words {
    [self.keyboardView removeWords:words];
    
    if (self.sg_updateSelectedKeyBoards) {
        NSMutableArray *keyboards = [self.selectedKeyBoards mutableCopy];
        [keyboards removeLastObject];
        self.selectedKeyBoards = keyboards;
        self.sg_updateSelectedKeyBoards(self.selectedKeyBoards);
    }
}

- (void)sg_spellingViewCallbackSpellingAnswer:(NSString *)answer {
    if (self.sg_dictationSpellAnswerCallback) {
        self.sg_dictationSpellAnswerCallback(answer);
    }
}

#pragma mark - ETLTVocabularyKeyboardViewDelegate

- (void)sg_keyboardEnsureDidClicked {
    if (self.sg_dictationEnsureDidClicked) {
        self.sg_dictationEnsureDidClicked();
    }
}

- (void)sg_keyboardDidSelectedWithWords:(NSString *)words atIndex:(NSInteger)index complete:(void (^)(void))complete {
    if ([self.spellingView addSpellingAnswer:words]) {
        complete();
        if (self.sg_updateSelectedKeyBoards) {
            NSMutableArray *keyboards = [self.selectedKeyBoards mutableCopy];
            [keyboards addObject:words];
            self.selectedKeyBoards = keyboards;
            self.sg_updateSelectedKeyBoards(self.selectedKeyBoards);
        }
    }
}

- (NSArray *)defaultKeyBoards {
    if (!_defaultKeyBoards) {
        _defaultKeyBoards = @[];
    }
    return _defaultKeyBoards;
}

- (NSArray *)selectedKeyBoards {
    if (!_selectedKeyBoards) {
        _selectedKeyBoards = @[];
    }
    return _selectedKeyBoards;
}

@end
