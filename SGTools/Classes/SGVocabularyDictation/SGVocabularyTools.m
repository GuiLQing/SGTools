//
//  SGVocabularyTools.m
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import "SGVocabularyTools.h"

@implementation SGVocabularyTools

/*
 单词去空格后字符，大于6个字母对2拆，单个单词如果是余数是1，最后一个是3拆
 单词去空格后字符，大于12个字母对3拆，单个单词如果是余数是1，最后一个是4拆，余数是2，最后一个是2拆
 单词去空格后字符，大于20个字母对4拆，单个单词如果是余数是1，最后一个是5拆，余数是2，最后一个是2拆，余数是3，最后一个是3拆
 单词去空格后字符，大于28小于55个字母对5拆，单个单词如果是余数是1，最后一个是6拆，余数是2，最后一个是2拆，余数是3，最后一个是3拆....
 格子数，12格，加几个随机乱序干扰
 */

/** 获取词组切割后的字符串数组 */
+ (NSArray<NSArray *> *)cutArrayByVocabulary:(NSString *)vocabulary {
    NSInteger cutLength = [self cutLengthByVocabulary:vocabulary];
    /** 先通过空格将词组分割开 */
    NSArray *vocabularys = [vocabulary componentsSeparatedByString:@" "];
    /** 再对每个单词进行拆分处理 */
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSString *singleWords in vocabularys) {
        if (![singleWords isEqualToString:@""]) {
            [resultArray addObject:[self cutSingleWords:singleWords length:cutLength]];
        }
    }
    return resultArray;
}

/** 获取字符串切割长度 */
+ (NSInteger)cutLengthByVocabulary:(NSString *)vocabulary {
    /** 去掉所有的空格计算长度 */
    NSInteger vocabularyLength = [vocabulary stringByReplacingOccurrencesOfString:@" " withString:@""].length;
    NSInteger length = 1;
    switch (vocabularyLength) {
        case 0 ... 6:
            length = 1;
            break;
        case 7 ... 12:
            length = 2;
            break;
        case 13 ... 20:
            length = 3;
            break;
        case 21 ... 28:
            length = 4;
            break;
        case 29 ... 55:
            length = 5;
            break;
        default:
            NSLog(@"暂不支持");
            break;
    }
    return length;
}

/** 获取单个单词切割后的字符串数组 */
+ (NSArray *)cutSingleWords:(NSString *)vocabulary length:(NSInteger)length {
    NSMutableArray *array = [NSMutableArray array];
    NSRange range = NSMakeRange(0, length);
    if (vocabulary.length % length == 0) {
        for (NSInteger i = 0; i < vocabulary.length / length; i ++) {
            [array addObject:[vocabulary substringWithRange:range]];
            range.location += length;
        }
    } else {
        for (NSInteger i = 0; i < vocabulary.length / length + 1; i ++) {
            if (vocabulary.length % length == 1 && i == vocabulary.length / length - 1) {
                range.length += 1;
                [array addObject:[vocabulary substringWithRange:range]];
                break;
            } else if (i == vocabulary.length / length) {
                range.length = vocabulary.length % length;
                [array addObject:[vocabulary substringWithRange:range]];
                break;
            } else {
                [array addObject:[vocabulary substringWithRange:range]];
                range.location += length;
            }
        }
    }
    return array;
}

/** 对结果数组增加干扰项，并随机打乱顺序 */
+ (NSArray *)addRandomSortResults:(NSArray *)results length:(NSInteger)length {
    NSMutableArray *array = [results mutableCopy];
    /** 增加干扰项 */
    for (NSInteger i = array.count + 1; i < 12; i ++) {
        NSMutableString *string = [NSMutableString string];
        for (NSInteger j = 0; j < length; j ++) {
            char num = arc4random_uniform(26);
            [string appendFormat:@"%c", num + 97];
        }
        [array addObject:string];
    }
    
    /** 随机排序 */
    return [array sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        int seed = arc4random_uniform(2);
        if (seed) {
            return [str1 compare:str2];
        } else {
            return [str2 compare:str1];
        }
    }];
}

@end
