//
//  SGVocabularyTools.h
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGVocabularyTools : NSObject

/** 获取词组切割后的字符串数组 */
+ (NSArray<NSArray *> *)cutArrayByVocabulary:(NSString *)vocabulary;
/** 获取字符串切割长度 */
+ (NSInteger)cutLengthByVocabulary:(NSString *)vocabulary;
/** 对结果数组增加干扰项，并随机打乱顺序 */
+ (NSArray *)addRandomSortResults:(NSArray *)results length:(NSInteger)length;

@end

NS_ASSUME_NONNULL_END
