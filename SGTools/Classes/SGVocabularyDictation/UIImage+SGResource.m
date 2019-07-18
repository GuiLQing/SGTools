//
//  UIImage+SGResource.m
//  SGVocabularyDictation
//
//  Created by lg on 2019/7/17.
//  Copyright © 2019 lg. All rights reserved.
//

#import "UIImage+SGResource.h"
#import <objc/runtime.h>

@implementation NSObject (Swizzle)

+ (void)swizzleClassSelectorWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Class class = self;
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    Class metaClass = object_getClass(class);
    // 若已经存在，则添加会失败
    BOOL didAddMethod = class_addMethod(metaClass,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    // 若原来的方法并不存在，则添加即可
    if (didAddMethod) {
        class_replaceMethod(metaClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end

@implementation UIImage (SGResource)

+ (void)load {
    [super load];
    [self swizzleClassSelectorWithOriginalSelector:@selector(imageNamed:) swizzledSelector:@selector(sg_imageNamed:)];
}

+ (UIImage *)sg_imageNamed:(NSString *)name {
    NSString *folderName = [name componentsSeparatedByString:@"_"][1];
    NSString *sg_folderName = [NSString stringWithFormat:@"SG%@", [folderName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[folderName substringToIndex:1] capitalizedString]]];
    NSString *imagePath = [NSString stringWithFormat:@"SGVocabularyDictation.bundle/%@/%@", sg_folderName, name];
    return [self sg_imageNamed:imagePath];
}

@end
