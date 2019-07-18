//
//  SGVocabularySpellingView.m
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import "SGVocabularySpellingView.h"
#import <Masonry/Masonry.h>
#import "UIImage+SGVocabularyResource.h"

#define SG_IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))

@interface SGVocabularySpellingCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation SGVocabularySpellingCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel = UILabel.alloc.init;
        self.textLabel.font = [UIFont systemFontOfSize:17.0f];
        self.textLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.numberOfLines = 1;
        [self.contentView addSubview:self.textLabel];
        
        self.lineView = UIView.alloc.init;
        self.lineView.backgroundColor = UIColor.blackColor;
        [self.contentView addSubview:self.lineView];
        
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self.contentView);
            make.width.mas_greaterThanOrEqualTo(15.0f);
            make.height.mas_greaterThanOrEqualTo(30.0f);
        }];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.contentView);
            make.height.mas_equalTo(1.0f);
        }];
        
        [self addObserver:self.textLabel forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSString *text = change[NSKeyValueChangeNewKey];
    self.lineView.hidden = !SG_IsStrEmpty(text);
}

- (void)dealloc {
    [self removeObserver:self.textLabel forKeyPath:@"text"];
}

@end

static NSString * const SGVocabularySpellingCellIdentifier = @"SGVocabularySpellingCellIdentifier";

@interface SGVocabularySpellingView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) NSMutableArray *answerArrays;

@end

@implementation SGVocabularySpellingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        
        [self addSubview:self.deleteButton];
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.collectionView.mas_right).offset(10.0f);
            make.size.mas_equalTo(CGSizeMake(30.0f, 30.0f));
            make.centerY.equalTo(self.mas_centerY);
        }];
    }
    return self;
}

- (void)setRightVocabularys:(NSArray<NSArray *> *)rightVocabularys {
    _rightVocabularys = rightVocabularys;
    
    self.answerArrays = [NSMutableArray array];
    _needAnswerCount = 0;
    for (NSArray *array in rightVocabularys) {
        NSMutableArray *answers = [NSMutableArray array];
        for (NSInteger i = 0; i < array.count; i ++) {
            [answers addObject:@""];
            _needAnswerCount ++; /** 通过数据量添加需要作答的数量 */
        }
        [self.answerArrays addObject:answers];
    }
    
    [self updateCollectionView];
}

- (void)updateCollectionView {
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    self.collectionView.contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize;
    
    CGFloat collectionViewWidth = MIN(self.collectionView.contentSize.width, CGRectGetWidth(self.bounds) - 40.0f);
    CGFloat collectionViewX = (CGRectGetWidth(self.bounds) - (collectionViewWidth + 40.0f)) / 2;
    CGRect collectionViewRect = self.collectionView.frame;
    collectionViewRect.size.width = collectionViewWidth;
    collectionViewRect.origin.x = collectionViewX;
    self.collectionView.frame = collectionViewRect;
}

- (void)answerDeleteAction {
    /** 需要倒序进行遍历 */
    NSMutableArray *answers = [self.answerArrays.reverseObjectEnumerator.allObjects mutableCopy];
    for (NSInteger i = 0; i < answers.count; i ++) {
        NSMutableArray *singleAnswers = [[answers[i] reverseObjectEnumerator].allObjects mutableCopy];
        for (NSInteger j = 0; j < singleAnswers.count; j ++) {
            NSString *words = singleAnswers[j];
            if (!SG_IsStrEmpty(words)) {
                singleAnswers[j] = @"";
                answers[i] = singleAnswers.reverseObjectEnumerator.allObjects;
                self.answerArrays = [answers.reverseObjectEnumerator.allObjects mutableCopy];
                _needAnswerCount ++;/** 减少一个已作答的，相当于多了一个需要作答的 */
                
                [self callbackSpellingAnswer];
                [self updateCollectionView];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(sg_spellingViewDeleteDidClickedWithWords:)]) {
                    [self.delegate sg_spellingViewDeleteDidClickedWithWords:words];
                }
                
                return;
            }
        }
    }
}

- (BOOL)addSpellingAnswer:(NSString *)answer {
    if (_needAnswerCount == 0) { /** 没有需要作答的了就直接返回NO */
        return NO;
    }
    for (NSInteger i = 0; i < self.answerArrays.count; i ++) {
        NSMutableArray *answers = self.answerArrays[i];
        for (NSInteger j = 0; j < answers.count; j ++) {
            NSString *singleWords = answers[j];
            if (SG_IsStrEmpty(singleWords)) {
                answers[j] = answer;
                self.answerArrays[i] = answers;
                _needAnswerCount --; /** 作答一个就将需要作答数减一 */
                
                [self callbackSpellingAnswer];
                [self updateCollectionView];
                return YES;
            }
        }
    }
    return NO;
}

- (void)callbackSpellingAnswer {
    NSMutableString *result = [NSMutableString string];
    for (NSArray *answers in self.answerArrays) {
        if (!SG_IsStrEmpty(result)) {
            [result appendString:@" "];
        }
        for (NSString *singleWords in answers) {
            if (!SG_IsStrEmpty(singleWords)) {
                [result appendString:singleWords];
            }
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sg_spellingViewCallbackSpellingAnswer:)]) {
        [self.delegate sg_spellingViewCallbackSpellingAnswer:result];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.answerArrays.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.answerArrays[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SGVocabularySpellingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SGVocabularySpellingCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.answerArrays[indexPath.section][indexPath.row];
    return cell;
}

#pragma mark - lazyloading

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = UICollectionViewFlowLayout.alloc.init;
        flowLayout.estimatedItemSize = CGSizeMake(15.0f, 30.0f);
        flowLayout.minimumLineSpacing = 2;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[SGVocabularySpellingCell class] forCellWithReuseIdentifier:SGVocabularySpellingCellIdentifier];
    }
    return _collectionView;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setImage:[UIImage sg_imageNamed:@"sg_dictation_icon_spelling_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(answerDeleteAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

@end
