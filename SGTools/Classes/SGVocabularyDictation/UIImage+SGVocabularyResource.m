//
//  UIImage+SGVocabularyResource.m
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import "UIImage+SGVocabularyResource.h"

@implementation NSBundle (SGVocabularyResource)

+ (instancetype)sg_defaultBundle {
    static NSBundle *_defaultBundle = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _defaultBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:NSClassFromString(@"SGVocabularyDictationView")] pathForResource:@"SGVocabularyDictation" ofType:@"bundle"]];
    });
    return _defaultBundle;
}

+ (NSString *)sg_bundlePathWithName:(NSString *)name {
    return [NSBundle.sg_defaultBundle.resourcePath stringByAppendingPathComponent:name];
}

@end

@implementation UIImage (SGVocabularyResource)

+ (UIImage *)sg_imageNamed:(NSString *)name {
    NSString *folderName = [name componentsSeparatedByString:@"_"][1];
    NSString *sg_folderName = [NSString stringWithFormat:@"SG%@", [folderName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[folderName substringToIndex:1] capitalizedString]]];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", sg_folderName, name];
    NSString *imageName = [NSBundle sg_bundlePathWithName:imagePath];
    return [UIImage imageNamed:imageName];
}

@end
