//
//  SGDragMoveView.m
//  SGDragTestDemo
//
//  Created by lancoo on 2020/5/14.
//  Copyright © 2020 lancoo. All rights reserved.
//

#import "SGDragMoveView.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSUInteger, SGMoveScrollDirection) {
    SGMoveScrollDirectionNone = 0,
    SGMoveScrollDirectionLeft,
    SGMoveScrollDirectionRight,
    SGMoveScrollDirectionUp,
    SGMoveScrollDirectionDown
};

@interface SGDragMoveView ()

/// 添加可滚动的视图容器
@property (nonatomic, strong) UIScrollView *scrollView;
/// 长按手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
/// 边缘滚动计时器
@property (nonatomic, strong) CADisplayLink *edgeTimer;
/// 所有子视图
@property (nonatomic, strong) NSMutableArray *items;
/// 当前拖拽视图
@property (nonatomic, strong) UIView *currentDragMoveItem;
/// 记录上一次拖拽坐标
@property (nonatomic, assign) CGPoint lastPoint;
/// 记录当前拖拽视图的起始位置（取消拖拽时复原位置使用）
@property (nonatomic, assign) CGRect originRect;
/// 记录当前拖拽视图的起始下标
@property (nonatomic, assign) NSInteger originIndex;

@end

@implementation SGDragMoveView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        
        _contentInset = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        _minimumLineSpacing = 10.0f;
        _minimumItemSpacing = 10.0f;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        self.scrollView.backgroundColor = UIColor.whiteColor;
        [self addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addLongPressGestureRecognizer];
    }
    return self;
}

- (void)setIsMoveDisabled:(BOOL)isMoveDisabled {
    _isMoveDisabled = isMoveDisabled;
    
    if (isMoveDisabled) {
        if (_longPressGesture) {
            [self.scrollView removeGestureRecognizer:_longPressGesture];
            _longPressGesture = nil;
        }
    } else {
        if (!_longPressGesture) [self addLongPressGestureRecognizer];
    }
}

- (void)setMinimumPressDuration:(NSTimeInterval)minimumPressDuration{
    _minimumPressDuration = minimumPressDuration;
    
    _longPressGesture.minimumPressDuration = minimumPressDuration;
}

- (void)setShakeLevel:(CGFloat)shakeLevel {
    _shakeLevel = MIN(10.0f, MAX(1.0f, shakeLevel));
}

- (void)reloadData {
    if (_items) {
        for (UIView *item in _items) {
            [item removeFromSuperview];
        }
        [_items removeAllObjects];
    }
    
    NSInteger numberOfItems = [self.dataSource numberOfItemsInDragMoveView:self];
    _items = [NSMutableArray arrayWithCapacity:numberOfItems];
    for (NSInteger i = 0; i < numberOfItems; i ++) {
        UIView *item = [self.dataSource dragMoveView:self viewForItemAtIndex:i];
        [self.scrollView addSubview:item];
        [_items addObject:item];
    }
    
    [self layoutItemsWithOriginIndex:0 endIndex:0 animation:NO];
}

#pragma mark - 子视图布局

- (void)layoutItemsWithOriginIndex:(NSInteger)originIndex endIndex:(NSInteger)endIndex animation:(BOOL)animation {
    CGFloat x = _contentInset.left;
    CGFloat y = _contentInset.top;
    CGFloat maxLineHeight = 0;
    
    /// 只从移动控件需要的最小的下标开始重新布局，前面的没有变动不需要重新布局
    NSInteger minIndex = MIN(_originIndex, endIndex);
    if (minIndex != 0) {
        /// 遍历寻找到当前行的首个控件，获取到当前行的x,y值，并从首个开始记录当前行的最大行高
        for (NSInteger i = minIndex; i >= 0; i --) {
            UIView *item = _items[i];
            if (CGRectGetMinX(item.frame) <= _contentInset.left) {
                minIndex = i;
                x = CGRectGetMinX(item.frame);
                y = CGRectGetMinY(item.frame);
                maxLineHeight = CGRectGetHeight(item.frame);
                break;
            }
        }
    }
    
    for (NSInteger i = minIndex; i < _items.count; i ++) {
        UIView *item = _items[i];

        if (x + CGRectGetWidth(item.bounds) <= CGRectGetWidth(self.scrollView.bounds) - _contentInset.right) {
            maxLineHeight = MAX(maxLineHeight, CGRectGetHeight(item.bounds));
        } else {
            /// 换行
            x = _contentInset.left;
            y += maxLineHeight + _minimumLineSpacing;
            maxLineHeight = CGRectGetHeight(item.bounds);
        }
        CGRect currentItemRect = CGRectMake(x, y, CGRectGetWidth(item.bounds), CGRectGetHeight(item.bounds));
        if (animation) {
            if (endIndex == i) {
                _originRect = currentItemRect;
            } else {
                [UIView animateWithDuration:0.25 animations:^{
                    item.frame = currentItemRect;
                }];
            }
        } else {
            item.frame = currentItemRect;
        }
        x += CGRectGetWidth(item.bounds) + _minimumItemSpacing;
    }

    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), y + maxLineHeight + _contentInset.bottom);
}

- (void)exchangeItemWithOriginIndex:(NSInteger)originIndex endIndex:(NSInteger)endIndex {
    NSInteger minIndex = MIN(_originIndex, endIndex);
    NSInteger maxIndex = MAX(_originIndex, endIndex);
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSInteger i = minIndex; i <= maxIndex; i ++) {
        [tempArray addObject:self.items[i]];
    }
    id obj = self.items[_originIndex];
    if (_originIndex == minIndex) {
        /// 往后移动
        [tempArray removeObjectAtIndex:0];
        [tempArray addObject:obj];
    } else {
        /// 往前移动
        [tempArray removeLastObject];
        [tempArray insertObject:obj atIndex:0];
    }
    
    [self.items replaceObjectsInRange:NSMakeRange(minIndex, maxIndex - minIndex + 1) withObjectsFromArray:tempArray];
}

- (void)moveItem {
    for (UIView *item in _items) {
        NSInteger currentIndex = [_items indexOfObject:item];
        if (currentIndex == _originIndex) {
            continue;
        }
        CGFloat spacingX = fabs(_currentDragMoveItem.center.x - item.center.x);
        CGFloat spacingY = fabs(_currentDragMoveItem.center.y - item.center.y);
        if (spacingX <= _currentDragMoveItem.bounds.size.width / 2.0f && spacingY <= _currentDragMoveItem.bounds.size.height / 2.0f) {
            /// 交换需要移动的数组内容
            [self exchangeItemWithOriginIndex:_originIndex endIndex:currentIndex];
            /// 布局需要移动的控件
            [self layoutItemsWithOriginIndex:_originIndex endIndex:currentIndex animation:YES];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(dragMoveView:moveItemFromIndex:toIndex:)]) {
                [self.delegate dragMoveView:self moveItemFromIndex:_originIndex toIndex:currentIndex];
            }
            
            /// 设置移动后的起始index
            _originIndex = currentIndex;
            break;
        }
    }
}

#pragma mark - 手势操作

- (void)addLongPressGestureRecognizer {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.minimumPressDuration = 0.1f;
    [self.scrollView addGestureRecognizer:longPress];
    _longPressGesture = longPress;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self gestureBegan:longPress];
    }
    if (longPress.state == UIGestureRecognizerStateChanged) {
        [self gestureChange:longPress];
    }
    if (longPress.state == UIGestureRecognizerStateCancelled ||
        longPress.state == UIGestureRecognizerStateEnded){
        [self gestureEndOrCancle:longPress];
    }
}

- (void)gestureBegan:(UILongPressGestureRecognizer *)longPress {
    _lastPoint = [longPress locationOfTouch:0 inView:longPress.view];
    for (UIView *item in self.items) {
        if (CGRectContainsPoint(item.frame, _lastPoint)) {
            _currentDragMoveItem = item;
            _originRect = item.frame;
            _originIndex = [self.items indexOfObject:item];
            [self.scrollView bringSubviewToFront:_currentDragMoveItem];
            [self startEdgeTimer];
            break;
        }
    }
}

- (void)gestureChange:(UILongPressGestureRecognizer *)longPress {
    CGPoint currentPoint = [longPress locationOfTouch:0 inView:longPress.view];
    CGFloat tranX = currentPoint.x - _lastPoint.x;
    CGFloat tranY = currentPoint.y - _lastPoint.y;
    _currentDragMoveItem.center = CGPointApplyAffineTransform(_currentDragMoveItem.center, CGAffineTransformMakeTranslation(tranX, tranY));
    _lastPoint = currentPoint;

    /// 重新布局子视图
    [self moveItem];
}

- (void)gestureEndOrCancle:(UILongPressGestureRecognizer *)longPress {
    [self stopEdgeTimer];
    _currentDragMoveItem.frame = _originRect;
    _currentDragMoveItem = nil;
}

#pragma mark - 边缘滚动定时器

- (void)startEdgeTimer {
    if (_isEdgeScrollDisabled) return;
    
    if (!_edgeTimer) {
        _edgeTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(edgeScroll)];
        [_edgeTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopEdgeTimer{
    if (_edgeTimer) {
        [_edgeTimer invalidate];
        _edgeTimer = nil;
    }
}

- (void)edgeScroll {
    SGMoveScrollDirection scrollDirection = SGMoveScrollDirectionNone;
    
    if (self.scrollView.bounds.size.height + self.scrollView.contentOffset.y - _currentDragMoveItem.center.y < _currentDragMoveItem.bounds.size.height / 2 && self.scrollView.bounds.size.height + self.scrollView.contentOffset.y < self.scrollView.contentSize.height) {
        scrollDirection = SGMoveScrollDirectionDown;
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y + 4) animated:NO];
        _currentDragMoveItem.center = CGPointMake(_currentDragMoveItem.center.x, _currentDragMoveItem.center.y + 4);
        _lastPoint.y += 4;
    } else if (_currentDragMoveItem.center.y - self.scrollView.contentOffset.y < _currentDragMoveItem.bounds.size.height / 2 && self.scrollView.contentOffset.y > 0) {
        scrollDirection = SGMoveScrollDirectionUp;
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y - 4) animated:NO];
        _currentDragMoveItem.center = CGPointMake(_currentDragMoveItem.center.x, _currentDragMoveItem.center.y - 4);
        _lastPoint.y -= 4;
    } else if (self.scrollView.bounds.size.width + self.scrollView.contentOffset.x - _currentDragMoveItem.center.x < _currentDragMoveItem.bounds.size.width / 2 && self.scrollView.bounds.size.width + self.scrollView.contentOffset.x < self.scrollView.contentSize.width) {
        scrollDirection = SGMoveScrollDirectionRight;
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + 4, self.scrollView.contentOffset.y) animated:NO];
        _currentDragMoveItem.center = CGPointMake(_currentDragMoveItem.center.x + 4, _currentDragMoveItem.center.y);
        _lastPoint.x += 4;
    } else if (_currentDragMoveItem.center.x - self.scrollView.contentOffset.x < _currentDragMoveItem.bounds.size.width / 2 && self.scrollView.contentOffset.x > 0) {
        scrollDirection = SGMoveScrollDirectionLeft;
        //这里的动画必须设为NO
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x - 4, self.scrollView.contentOffset.y) animated:NO];
        _currentDragMoveItem.center = CGPointMake(_currentDragMoveItem.center.x - 4, _currentDragMoveItem.center.y);
        _lastPoint.x -= 4;
    }
}

@end
