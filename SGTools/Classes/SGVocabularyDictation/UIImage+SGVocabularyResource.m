//
//  UIImage+SGVocabularyResource.m
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import "UIImage+SGVocabularyResource.h"

@implementation UIImage (SGVocabularyResource)

+ (UIImage *)sg_imageNamed:(NSString *)name {
    NSString *folderName = [name componentsSeparatedByString:@"_"][1];
    NSString *sg_folderName = [NSString stringWithFormat:@"SG%@", [folderName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[folderName substringToIndex:1] capitalizedString]]];
    NSString *imagePath = [NSString stringWithFormat:@"SGVocabularyDictation.bundle/%@/%@", sg_folderName, name];
    return [self sg_imageNamed:imagePath];
}

@end
