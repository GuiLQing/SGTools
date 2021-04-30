//
//  XWDragCellCollectionView.m
//  PanCollectionView
//
//  Created by YouLoft_MacMini on 16/1/4.
//  Copyright © 2016年 wazrx. All rights reserved.
//

#import "SGDragCellCollectionView.h"
#import <AudioToolbox/AudioToolbox.h>

#define angelToRandian(x)  ((x)/180.0*M_PI)

typedef NS_ENUM(NSUInteger, SGDragCellCollectionViewScrollDirection) {
    SGDragCellCollectionViewScrollDirectionNone = 0,
    SGDragCellCollectionViewScrollDirectionLeft,
    SGDragCellCollectionViewScrollDirectionRight,
    SGDragCellCollectionViewScrollDirectionUp,
    SGDragCellCollectionViewScrollDirectionDown
};

@interface SGDragCellCollectionView ()
@property (nonatomic, strong) NSIndexPath *originalIndexPath;
@property (nonatomic, weak) UICollectionViewCell *orignalCell;
@property (nonatomic, assign) CGPoint orignalCenter;
@property (nonatomic, strong) NSIndexPath *moveIndexPath;
@property (nonatomic, weak) UIView *tempMoveCell;
@property (nonatomic, weak) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) CADisplayLink *edgeTimer;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) SGDragCellCollectionViewScrollDirection scrollDirection;
@property (nonatomic, assign) CGFloat oldMinimumPressDuration;
@property (nonatomic, assign, getter=isObservering) BOOL observering;
@property (nonatomic) BOOL isPanning;

@end

@implementation SGDragCellCollectionView

@dynamic delegate;
@dynamic dataSource;

#pragma mark - initailize methods

- (void)dealloc{
    [self sg_removeContentOffsetObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self sg_initializeProperty];
        [self sg_addGesture];
        //添加监听
        [self sg_addContentOffsetObserver];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self sg_initializeProperty];
        [self sg_addGesture];
        //添加监听
        [self sg_addContentOffsetObserver];
    }
    return self;
}

- (void)sg_initializeProperty{
    _minimumPressDuration = 1;
    _edgeScrollEable = YES;
    _shakeWhenMoveing = YES;
    _shakeLevel = 4.0f;
}

- (void)setIsMoveDisabled:(BOOL)isMoveDisabled {
    _isMoveDisabled = isMoveDisabled;
    
    if (isMoveDisabled) {
        [self removeGestureRecognizer:_longPressGesture];
        _longPressGesture = nil;
    } else {
        if (!_longPressGesture) [self sg_addGesture];
    }
}

#pragma mark - longPressGesture methods

/**
 *  添加一个自定义的滑动手势
 */
- (void)sg_addGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(xwp_longPressed:)];
    _longPressGesture = longPress;
    longPress.minimumPressDuration = _minimumPressDuration;
    [self addGestureRecognizer:longPress];
}

/**
 *  监听手势的改变
 */
- (void)xwp_longPressed:(UILongPressGestureRecognizer *)longPressGesture{
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [self sg_gestureBegan:longPressGesture];
    }
    if (longPressGesture.state == UIGestureRecognizerStateChanged) {
        [self sg_gestureChange:longPressGesture];
    }
    if (longPressGesture.state == UIGestureRecognizerStateCancelled ||
        longPressGesture.state == UIGestureRecognizerStateEnded){
        [self sg_gestureEndOrCancle:longPressGesture];
    }
}

/**
 *  手势开始
 */
- (void)sg_gestureBegan:(UILongPressGestureRecognizer *)longPressGesture{
    //获取手指所在的cell
    _originalIndexPath = [self indexPathForItemAtPoint:[longPressGesture locationOfTouch:0 inView:longPressGesture.view]];
    if ([self sg_indexPathIsExcluded:_originalIndexPath]) {
        return;
    }
    _isPanning = YES;
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
//    UIImage *snap;
//    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, 1.0f, 0);
//    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
//    snap = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    UIView *tempMoveCell = [UIView new];
//    tempMoveCell.layer.contents = (__bridge id)snap.CGImage;
    UIView *tempMoveCell = [cell snapshotViewAfterScreenUpdates:YES];
    cell.hidden = YES;
    //记录cell，不能通过_originalIndexPath,在重用之后原indexpath所对应的cell可能不会是这个cell了
    _orignalCell = cell;
    //记录ceter，同理不能通过_originalIndexPath来获取cell
    _orignalCenter = cell.center;
    _tempMoveCell = tempMoveCell;
    _tempMoveCell.frame = cell.frame;
    [self addSubview:_tempMoveCell];
    //开启边缘滚动定时器
    [self sg_setEdgeTimer];
    //开启抖动
    if (!_sg_editing) {
        [self sg_shakeAllCell];
    }
    _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
    //通知代理
    if ([self.delegate respondsToSelector:@selector(sg_dragCellCollectionView:cellWillBeginMoveAtIndexPath:)]) {
        [self.delegate sg_dragCellCollectionView:self cellWillBeginMoveAtIndexPath:_originalIndexPath];
    }
}
/**
 *  手势拖动
 */
- (void)sg_gestureChange:(UILongPressGestureRecognizer *)longPressGesture{
    //通知代理
    if ([self.delegate respondsToSelector:@selector(sg_dragCellCollectionViewCellisMoving:)]) {
        [self.delegate sg_dragCellCollectionViewCellisMoving:self];
    }
    CGFloat tranX = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].x - _lastPoint.x;
    CGFloat tranY = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].y - _lastPoint.y;
    _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
    _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
    [self sg_moveCell];
}

/**
 *  手势取消或者结束
 */
- (void)sg_gestureEndOrCancle:(UILongPressGestureRecognizer *)longPressGesture{
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
    self.userInteractionEnabled = NO;
    _isPanning = NO;
    [self sg_stopEdgeTimer];
    //通知代理
    if ([self.delegate respondsToSelector:@selector(sg_dragCellCollectionViewCellEndMoving:)]) {
        [self.delegate sg_dragCellCollectionViewCellEndMoving:self];
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.tempMoveCell.center = self.orignalCenter;
    } completion:^(BOOL finished) {
        [self sg_stopShakeAllCell];
        [self.tempMoveCell removeFromSuperview];
        cell.hidden = NO;
        self.orignalCell.hidden = NO;
        self.userInteractionEnabled = YES;
        self.originalIndexPath = nil;
    }];
}

#pragma mark - setter methods

- (void)setMinimumPressDuration:(NSTimeInterval)minimumPressDuration{
    _minimumPressDuration = minimumPressDuration;
    _longPressGesture.minimumPressDuration = minimumPressDuration;
}

- (void)setShakeLevel:(CGFloat)shakeLevel{
    CGFloat level = MAX(1.0f, shakeLevel);
    _shakeLevel = MIN(level, 10.0f);
}

#pragma mark - timer methods

- (void)sg_setEdgeTimer{
    if (!_edgeTimer && _edgeScrollEable) {
        _edgeTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(sg_edgeScroll)];
        [_edgeTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)sg_stopEdgeTimer{
    if (_edgeTimer) {
        [_edgeTimer invalidate];
        _edgeTimer = nil;
    }
}


#pragma mark - private methods

- (void)sg_moveCell{
    for (UICollectionViewCell *cell in [self visibleCells]) {
        if ([self indexPathForCell:cell] == _originalIndexPath || [self sg_indexPathIsExcluded:[self indexPathForCell:cell]]) {
            continue;
        }
        //计算中心距
        CGFloat spacingX = fabs(_tempMoveCell.center.x - cell.center.x);
        CGFloat spacingY = fabs(_tempMoveCell.center.y - cell.center.y);
        if (spacingX <= _tempMoveCell.bounds.size.width / 2.0f && spacingY <= _tempMoveCell.bounds.size.height / 2.0f) {
            _moveIndexPath = [self indexPathForCell:cell];
            _orignalCell = cell;
            _orignalCenter = cell.center;
            //更新数据源
            [self sg_updateDataSource];
            //移动
            NSLog(@"%@", [self cellForItemAtIndexPath:_originalIndexPath]);
//            cell.hidden = YES;
            [CATransaction begin];
            [self moveItemAtIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
            [CATransaction setCompletionBlock:^{
                NSLog(@"动画完成");
            }];
            [CATransaction commit];
            //通知代理
            if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:moveCellFromIndexPath:toIndexPath:)]) {
                [self.delegate dragCellCollectionView:self moveCellFromIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
            }
            //设置移动后的起始indexPath
            _originalIndexPath = _moveIndexPath;
            break;
        }
    }
}

/**
 *  更新数据源
 */
- (void)sg_updateDataSource{
    NSMutableArray *temp = @[].mutableCopy;
    //获取数据源
    if ([self.dataSource respondsToSelector:@selector(sg_dataSourceArrayOfCollectionView:)]) {
        [temp addObjectsFromArray:[self.dataSource sg_dataSourceArrayOfCollectionView:self]];
    }
    //判断数据源是单个数组还是数组套数组的多section形式，YES表示数组套数组
    BOOL dataTypeCheck = ([self numberOfSections] != 1 || ([self numberOfSections] == 1 && [temp[0] isKindOfClass:[NSArray class]]));
    if (dataTypeCheck) {
        for (int i = 0; i < temp.count; i ++) {
            [temp replaceObjectAtIndex:i withObject:[temp[i] mutableCopy]];
        }
    }
    if (_moveIndexPath.section == _originalIndexPath.section) {
        NSMutableArray *orignalSection = dataTypeCheck ? temp[_originalIndexPath.section] : temp;
        if (_moveIndexPath.item > _originalIndexPath.item) {
            for (NSUInteger i = _originalIndexPath.item; i < _moveIndexPath.item ; i ++) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
            }
        }else{
            for (NSUInteger i = _originalIndexPath.item; i > _moveIndexPath.item ; i --) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
            }
        }
    }else{
        NSMutableArray *orignalSection = temp[_originalIndexPath.section];
        NSMutableArray *currentSection = temp[_moveIndexPath.section];
        [currentSection insertObject:orignalSection[_originalIndexPath.item] atIndex:_moveIndexPath.item];
        [orignalSection removeObject:orignalSection[_originalIndexPath.item]];
    }
    //将重排好的数据传递给外部
    if ([self.delegate respondsToSelector:@selector(sg_dragCellCollectionView:newDataArrayAfterMove:)]) {
        [self.delegate sg_dragCellCollectionView:self newDataArrayAfterMove:temp.copy];
    }
}

- (void)sg_edgeScroll{
    [self sg_setScrollDirection];
    switch (_scrollDirection) {
        case SGDragCellCollectionViewScrollDirectionLeft:{
            //这里的动画必须设为NO
            [self setContentOffset:CGPointMake(self.contentOffset.x - 4, self.contentOffset.y) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x - 4, _tempMoveCell.center.y);
            _lastPoint.x -= 4;
            
        }
            break;
        case SGDragCellCollectionViewScrollDirectionRight:{
            [self setContentOffset:CGPointMake(self.contentOffset.x + 4, self.contentOffset.y) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x + 4, _tempMoveCell.center.y);
            _lastPoint.x += 4;
            
        }
            break;
        case SGDragCellCollectionViewScrollDirectionUp:{
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - 4) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x, _tempMoveCell.center.y - 4);
            _lastPoint.y -= 4;
        }
            break;
        case SGDragCellCollectionViewScrollDirectionDown:{
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + 4) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x, _tempMoveCell.center.y + 4);
            _lastPoint.y += 4;
        }
            break;
        default:
            break;
    }
    
}

- (void)sg_shakeAllCell{
    if (!_shakeWhenMoveing) {
        //没有开启抖动只需要遍历设置个cell的hidden属性
        NSArray *cells = [self visibleCells];
        for (UICollectionViewCell *cell in cells) {
            //顺便设置各个cell的hidden属性，由于有cell被hidden，其hidden状态可能被冲用到其他cell上,不能直接利用_originalIndexPath相等判断，这很坑
            BOOL hidden = _originalIndexPath && [self indexPathForCell:cell].item == _originalIndexPath.item && [self indexPathForCell:cell].section == _originalIndexPath.section;
            cell.hidden = hidden;
        }
        return;
    }
    CAKeyframeAnimation* anim=[CAKeyframeAnimation animation];
    anim.keyPath=@"transform.rotation";
    anim.values=@[@(angelToRandian(-_shakeLevel)),@(angelToRandian(_shakeLevel)),@(angelToRandian(-_shakeLevel))];
    anim.repeatCount=MAXFLOAT;
    anim.duration=0.2;
    NSArray *cells = [self visibleCells];
    for (UICollectionViewCell *cell in cells) {
        if ([self sg_indexPathIsExcluded:[self indexPathForCell:cell]]) {
            continue;
        }
        /**如果加了shake动画就不用再加了*/
        if (![cell.layer animationForKey:@"shake"]) {
            [cell.layer addAnimation:anim forKey:@"shake"];
        }
        //顺便设置各个cell的hidden属性，由于有cell被hidden，其hidden状态可能被冲用到其他cell上
        BOOL hidden = _originalIndexPath && [self indexPathForCell:cell].item == _originalIndexPath.item && [self indexPathForCell:cell].section == _originalIndexPath.section;
        cell.hidden = hidden;
    }
    if (![_tempMoveCell.layer animationForKey:@"shake"]) {
        [_tempMoveCell.layer addAnimation:anim forKey:@"shake"];
    }
}

- (void)sg_stopShakeAllCell{
    if (!_shakeWhenMoveing || _sg_editing) {
        return;
    }
    NSArray *cells = [self visibleCells];
    for (UICollectionViewCell *cell in cells) {
        [cell.layer removeAllAnimations];
    }
    [_tempMoveCell.layer removeAllAnimations];
}

- (void)sg_setScrollDirection{
    _scrollDirection = SGDragCellCollectionViewScrollDirectionNone;
    if (self.bounds.size.height + self.contentOffset.y - _tempMoveCell.center.y < _tempMoveCell.bounds.size.height / 2 && self.bounds.size.height + self.contentOffset.y < self.contentSize.height) {
        _scrollDirection = SGDragCellCollectionViewScrollDirectionDown;
    }
    if (_tempMoveCell.center.y - self.contentOffset.y < _tempMoveCell.bounds.size.height / 2 && self.contentOffset.y > 0) {
        _scrollDirection = SGDragCellCollectionViewScrollDirectionUp;
    }
    if (self.bounds.size.width + self.contentOffset.x - _tempMoveCell.center.x < _tempMoveCell.bounds.size.width / 2 && self.bounds.size.width + self.contentOffset.x < self.contentSize.width) {
        _scrollDirection = SGDragCellCollectionViewScrollDirectionRight;
    }
    
    if (_tempMoveCell.center.x - self.contentOffset.x < _tempMoveCell.bounds.size.width / 2 && self.contentOffset.x > 0) {
        _scrollDirection = SGDragCellCollectionViewScrollDirectionLeft;
    }
}

- (void)sg_addContentOffsetObserver{
    if (_observering) return;
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    _observering = YES;
}

- (void)sg_removeContentOffsetObserver{
    if (!_observering) return;
    [self removeObserver:self forKeyPath:@"contentOffset"];
    _observering = NO;
}

- (BOOL)sg_indexPathIsExcluded:(NSIndexPath *)indexPath{
    if (!indexPath || ![self.delegate respondsToSelector:@selector(sg_excludeIndexPathsWhenMoveDragCellCollectionView:)]) {
        return NO;
    }
    NSArray<NSIndexPath *> *excludeIndexPaths = [self.delegate sg_excludeIndexPathsWhenMoveDragCellCollectionView:self];
    __block BOOL flag = NO;
    [excludeIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.item == indexPath.item && obj.section == indexPath.section) {
            flag = YES;
            *stop = YES;
        }
    }];
    return flag;
}

#pragma mark - public methods

- (void)sg_enterEditingModel{
    _sg_editing = YES;
    _oldMinimumPressDuration =  _longPressGesture.minimumPressDuration;
    _longPressGesture.minimumPressDuration = 0;
    if (_shakeWhenMoveing) {
        [self sg_shakeAllCell];
        [self sg_addContentOffsetObserver];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sg_foreground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

- (void)sg_stopEditingModel{
    _sg_editing = NO;
    _longPressGesture.minimumPressDuration = _oldMinimumPressDuration;
    [self sg_stopShakeAllCell];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}


#pragma mark - overWrite methods

/**
 *  重写hitTest事件，判断是否应该相应自己的滑动手势，还是系统的滑动手势
 */

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    _longPressGesture.enabled = [self indexPathForItemAtPoint:point];
    return [super hitTest:point withEvent:event];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (![keyPath isEqualToString:@"contentOffset"]) return;
    if (_sg_editing || _isPanning) {
        [self sg_shakeAllCell];
    }else if (!_sg_editing && !_isPanning){
        [self sg_stopShakeAllCell];
    }
}

#pragma mark - notification

- (void)sg_foreground{
    if (_sg_editing) {
        [self sg_shakeAllCell];
    }
}



@end
