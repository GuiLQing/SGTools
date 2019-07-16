//
//  SGCollectionViewFlowLayout.h
//  Pods-SGTools_Example
//
//  Created by lg on 2019/7/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,SGAlignType){
    SGAlignWithLeft,
    SGAlignWithCenter,
    SGAlignWithRight
};

@interface SGCollectionViewFlowLayout : UICollectionViewFlowLayout

//两个Cell之间的距离
@property (nonatomic, assign) CGFloat betweenOfCell;
//cell对齐方式
@property (nonatomic, assign) SGAlignType cellType;

-(instancetype)initWthType:(SGAlignType)cellType;
//全能初始化方法 其他方式初始化最终都会走到这里
-(instancetype)initWithType:(SGAlignType)cellType betweenOfCell:(CGFloat)betweenOfCell;

@end

NS_ASSUME_NONNULL_END
