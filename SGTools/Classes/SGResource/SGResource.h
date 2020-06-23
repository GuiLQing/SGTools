//
//  SGResource.h
//  AFNetworking
//
//  Created by lancoo on 2020/3/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGResource : NSObject

+ (SGResource *)sg_defaultResource;

- (NSArray *)sg_loadingImages;

- (UIImage *)sg_loadEmptyImage;

- (UIImage *)sg_loadErrorImage;

@end

@interface UIImage (SGResource)

+ (UIImage * _Nonnull (^)(NSString * _Nullable, NSString * _Nullable))sg_imageFolderPath;

@end

@interface NSBundle (SGResource)

+ (NSString * _Nonnull (^)(NSString * _Nullable))sg_resourcePath;

+ (NSString * _Nonnull (^)(NSString * _Nullable, NSString * _Nullable))sg_resourceFolderPath;

@end

NS_ASSUME_NONNULL_END
