//
//  SGMoveCollectionView.m
//  AFNetworking
//
//  Created by lancoo on 2020/4/22.
//

#import "SGMoveCollectionView.h"

@interface SGMoveCollectionView ()

@property (nonatomic, weak) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation SGMoveCollectionView

@dynamic delegate;
@dynamic dataSource;

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        _minimumPressDuration = 1.0;
        
        [self sg_addGesture];
    }
    return self;
}

/// 更新数据源
- (void)sg_updateDataSourceWithSourceIndexPath:(NSIndexPath *)sourceIndexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath {
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
    if (destinationIndexPath.section == sourceIndexPath.section) {
        NSMutableArray *orignalSection = dataTypeCheck ? temp[sourceIndexPath.section] : temp;
        if (destinationIndexPath.item > sourceIndexPath.item) {
            for (NSUInteger i = sourceIndexPath.item; i < destinationIndexPath.item ; i ++) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
            }
        }else{
            for (NSUInteger i = sourceIndexPath.item; i > destinationIndexPath.item ; i --) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
            }
        }
    }else{
        NSMutableArray *orignalSection = temp[sourceIndexPath.section];
        NSMutableArray *currentSection = temp[destinationIndexPath.section];
        [currentSection insertObject:orignalSection[sourceIndexPath.item] atIndex:destinationIndexPath.item];
        [orignalSection removeObject:orignalSection[sourceIndexPath.item]];
    }
    //将重排好的数据传递给外部
    if ([self.delegate respondsToSelector:@selector(sg_dragCellCollectionView:newDataArrayAfterMove:)]) {
        [self.delegate sg_dragCellCollectionView:self newDataArrayAfterMove:temp.copy];
    }
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

#pragma mark - UILongPressGestureRecognizer

- (void)sg_addGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sg_longPressed:)];
    _longPressGesture = longPress;
    longPress.minimumPressDuration = _minimumPressDuration;
    [self addGestureRecognizer:longPress];
}

- (void)sg_longPressed:(UILongPressGestureRecognizer *)longPressGesture {
    
    CGPoint point = [longPressGesture locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan: {
            if (!indexPath) break;
            if (@available(iOS 9.0, *)) {
                [self beginInteractiveMovementForItemAtIndexPath:indexPath];
            }
        }
            break;
        
        case UIGestureRecognizerStateChanged:
            if (@available(iOS 9.0, *)) {
                [self updateInteractiveMovementTargetPosition:point];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (@available(iOS 9.0, *)) {
                [self endInteractiveMovement];
            }
            break;
            
        default:
            if (@available(iOS 9.0, *)) {
                [self cancelInteractiveMovement];
            }
            break;
    }
}

#pragma mark - setter methods

- (void)setMinimumPressDuration:(NSTimeInterval)minimumPressDuration{
    _minimumPressDuration = minimumPressDuration;
    _longPressGesture.minimumPressDuration = minimumPressDuration;
}

@end
