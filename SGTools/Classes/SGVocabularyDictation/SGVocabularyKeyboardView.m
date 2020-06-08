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

@property (nonatomic, strong) UIImageView *shadowImageView;

@property (nonatomic, assign) BOOL keyboardSelected;

@property (nonatomic, assign) BOOL isReturnKeyboard;

@end

@implementation SGVocabularyKeyboardCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backImageView = UIImageView.alloc.init;
        [self addSubview:_backImageView];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self.contentView);
                make.height.equalTo(self.backImageView.mas_width).multipliedBy(80.0f / 228);
            }];
        } else {
            [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView);
            }];
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _shadowImageView = UIImageView.alloc.init;
            [self.contentView addSubview:_shadowImageView];
            [_shadowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.contentView);
                make.top.equalTo(self.backImageView.mas_bottom);
                make.height.equalTo(self.shadowImageView.mas_width).multipliedBy(20.0f / 234);
            }];
        }
        
        _keyboardLabel = UILabel.alloc.init;
        _keyboardLabel.textColor = UIColor.whiteColor;
        _keyboardLabel.textAlignment = NSTextAlignmentCenter;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _keyboardLabel.font = [UIFont systemFontOfSize:25.0f];
        } else {
            _keyboardLabel.font = [UIFont systemFontOfSize:15.0f];
        }
        [self addSubview:_keyboardLabel];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_keyboardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.backImageView);
            }];
        } else {
            [_keyboardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self.contentView);
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    make.bottom.equalTo(self.contentView.mas_bottom).offset(-15.0f);
                } else {
                    make.bottom.equalTo(self.contentView.mas_bottom).offset(-10.0f);
                }
            }];
        }
    }
    return self;
}

- (void)setKeyboardSelected:(BOOL)keyboardSelected {
    _keyboardSelected = keyboardSelected;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.backImageView.image = [UIImage sg_vr_imageNamed:keyboardSelected ? @"sg_dictation_icon_keyboard_selected_ipad" : @"sg_dictation_icon_keyboard_default_ipad"];
        self.shadowImageView.image = [UIImage sg_vr_imageNamed:keyboardSelected ? @"sg_dictation_icon_keyboard_selected_shadow_ipad" : @"sg_dictation_icon_keyboard_default_shadow_ipad"];
    } else {
        self.backImageView.image = [UIImage sg_vr_imageNamed:keyboardSelected ? @"sg_dictation_icon_keyboard_selected" : @"sg_dictation_icon_keyboard_default"];
    }
}

- (void)setIsReturnKeyboard:(BOOL)isReturnKeyboard {
    _isReturnKeyboard = isReturnKeyboard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.backImageView.image = [UIImage sg_vr_imageNamed:@"sg_dictation_icon_keyboard_ensure_ipad"];
        self.shadowImageView.image = [UIImage sg_vr_imageNamed:@"sg_dictation_icon_keyboard_ensure_shadow_ipad"];
    } else {
        self.backImageView.image = [UIImage sg_vr_imageNamed:@"sg_dictation_icon_keyboard_ensure"];
    }
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

- (void)setSelectedKeyBoards:(NSArray<NSString *> *)selectedKeyBoards {
    _selectedKeyBoards = selectedKeyBoards;
    
    for (NSString *text in selectedKeyBoards) {
        if ([self.randomVocabularys containsObject:text]) {
            for (NSInteger index = 0; index < self.randomVocabularys.count; index ++) {
                NSString *word = self.randomVocabularys[index];
                if ([word isEqualToString:text]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    if (![self.selectedWordsDics.allKeys containsObject:indexPath]) {
                        [self.selectedWordsDics setObject:text forKey:indexPath];
                        break;
                    }
                }
            }
        }
    }
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
        cell.isReturnKeyboard = YES;
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
        CGFloat itemWidth = (CGRectGetWidth(self.bounds) - 3 * 10) / 4;
        CGFloat itemHeight = itemWidth * (84.0 / 136);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            itemHeight = itemWidth * (80.0 / 228 + 20.0 / 234);
        }
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
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
