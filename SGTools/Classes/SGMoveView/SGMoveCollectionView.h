//
//  SGMoveCollectionView.h
//  AFNetworking
//
//  Created by lancoo on 2020/4/22.
//

#import <UIKit/UIKit.h>
@class SGMoveCollectionView;

NS_ASSUME_NONNULL_BEGIN

@protocol  SGMoveCollectionViewDelegate<UICollectionViewDelegate>

@required

/// 当数据源更新的到时候调用，必须实现，需将新的数据源设置为当前tableView的数据源(例如 :_data = newDataArray)
/// @param collectionView  SGMoveCollectionView
/// @param newDataArray  更新后的数据源
- (void)sg_dragCellCollectionView:(SGMoveCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray;

@end

@protocol  SGMoveCollectionViewDataSource <UICollectionViewDataSource>

@required

/// 返回整个CollectionView的数据，必须实现，需根据数据进行移动后的数据重排
- (NSArray *)sg_dataSourceArrayOfCollectionView:(SGMoveCollectionView *)collectionView;

@end

@interface SGMoveCollectionView : UICollectionView

@property (nonatomic, assign) id<SGMoveCollectionViewDelegate> delegate;

@property (nonatomic, assign) id<SGMoveCollectionViewDataSource> dataSource;

/// 禁止移动
@property (nonatomic, assign) BOOL isMoveDisabled;
/**长按多少秒触发拖动手势，默认1秒，如果设置为0，表示手指按下去立刻就触发拖动*/
@property (nonatomic, assign) NSTimeInterval minimumPressDuration;

- (void)sg_updateDataSourceWithSourceIndexPath:(NSIndexPath *)sourceIndexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath;

@end

NS_ASSUME_NONNULL_END
