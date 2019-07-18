//
//  SGVocabularyKeyboardView.m
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import "SGVocabularyKeyboardView.h"
#import <Masonry/Masonry.h>
#import "UIImage+SGVocabularyResource.h"

@interface SGVocabularyKeyboardCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *keyboardLabel;
@property (nonatomic, strong) UIImageView *backImageView;

@property (nonatomic, assign) BOOL keyboardSelected;

@end

@implementation SGVocabularyKeyboardCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backImageView = UIImageView.alloc.init;
        _backImageView.frame = self.bounds;
        [self addSubview:_backImageView];
        
        _keyboardLabel = UILabel.alloc.init;
        _keyboardLabel.textColor = UIColor.whiteColor;
        _keyboardLabel.textAlignment = NSTextAlignmentCenter;
        _keyboardLabel.font = [UIFont systemFontOfSize:15.0f];
        [self addSubview:_keyboardLabel];
        [_keyboardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10.0f);
        }];
    }
    return self;
}

- (void)setKeyboardSelected:(BOOL)keyboardSelected {
    _keyboardSelected = keyboardSelected;
    self.backImageView.image = [UIImage sg_imageNamed:keyboardSelected ? @"sg_dictation_icon_keyboard_selected" : @"sg_dictation_icon_keyboard_default"];
}

@end

static NSString * const SGVocabularyKeyboardCellIdentifier = @"SGVocabularyKeyboardCellIdentifier";

@interface SGVocabularyKeyboardView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableDictionary *selectedWordsDics;

@end

@implementation SGVocabularyKeyboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)setRandomVocabularys:(NSArray<NSString *> *)randomVocabularys {
    _randomVocabularys = randomVocabularys;
    
    [self.selectedWordsDics removeAllObjects];
    [self.collectionView reloadData];
}

- (void)removeWords:(NSString *)words {
    if ([self.selectedWordsDics.allValues containsObject:words]) {
        [self.selectedWordsDics removeObjectForKey:[self.selectedWordsDics allKeysForObject:words].firstObject];
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.randomVocabularys.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SGVocabularyKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SGVocabularyKeyboardCellIdentifier forIndexPath:indexPath];
    if (indexPath.row == self.randomVocabularys.count) {
        /** 回车按钮 */
        cell.keyboardLabel.text = @"";
        cell.backImageView.image = [UIImage sg_imageNamed:@"sg_dictation_icon_keyboard_ensure"];
    } else {
        cell.keyboardLabel.text = self.randomVocabularys[indexPath.row];
        cell.keyboardSelected = [self.selectedWordsDics.allKeys containsObject:indexPath];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == self.randomVocabularys.count) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sg_keyboardEnsureDidClicked)]) {
            [self.delegate sg_keyboardEnsureDidClicked];
        }
    } else {
        if (![self.selectedWordsDics.allKeys containsObject:indexPath]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(sg_keyboardDidSelectedWithWords:atIndex:complete:)]) {
                
                SGVocabularyKeyboardCell *cell = (SGVocabularyKeyboardCell *)[collectionView cellForItemAtIndexPath:indexPath];
                NSString *words = self.randomVocabularys[indexPath.row];
                [self.delegate sg_keyboardDidSelectedWithWords:words atIndex:indexPath.row complete:^{
                    cell.keyboardSelected = YES;
                    [self.selectedWordsDics setObject:words forKey:indexPath];
                }];
                
            }
        }
    }
}

#pragma mark - lazyloading

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = UICollectionViewFlowLayout.alloc.init;
        flowLayout.itemSize = CGSizeMake((CGRectGetWidth(self.bounds) - 3 * 10) / 4, 45.0f);
        flowLayout.minimumLineSpacing = 10.0f;
        flowLayout.minimumInteritemSpacing = 10.0f;
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[SGVocabularyKeyboardCell class] forCellWithReuseIdentifier:SGVocabularyKeyboardCellIdentifier];
    }
    return _collectionView;
}

- (NSMutableDictionary *)selectedWordsDics {
    if (!_selectedWordsDics) {
        _selectedWordsDics = [NSMutableDictionary dictionary];
    }
    return _selectedWordsDics;
}

@end
