//
//  SGResource.m
//  AFNetworking
//
//  Created by lancoo on 2020/3/27.
//

#import "SGResource.h"

@interface SGResource ()

@property (nonatomic, strong) NSArray *sg_loadingImages;

@property (nonatomic, strong) UIImage *sg_loadEmptyImage;

@property (nonatomic, strong) UIImage *sg_loadErrorImage;

@end

@implementation SGResource

+ (SGResource *)sg_defaultResource {
    static SGResource *_resource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _resource = [[SGResource alloc] init];
    });
    return _resource;
}

- (NSArray *)sg_loadingImages {
    if (!_sg_loadingImages) {
        NSMutableArray *images = [NSMutableArray array];
        for (NSInteger i = 63; i >= 0; i --) {
            UIImage *image = [UIImage imageWithContentsOfFile:NSBundle.sg_resourceFolderPath([NSString stringWithFormat:@"sg_icon_loading_%zd.jpg", i], @"SGLoading")];
            if (image) [images addObject:image];
        }
        _sg_loadingImages = images;
    }
    return _sg_loadingImages;
}

- (UIImage *)sg_loadEmptyImage {
    if (!_sg_loadEmptyImage) {
        _sg_loadEmptyImage = [UIImage imageWithContentsOfFile:NSBundle.sg_resourceFolderPath(@"sg_icon_loading_empty", @"SGLoadResult")];
    }
    return _sg_loadEmptyImage;
}

- (UIImage *)sg_loadErrorImage {
    if (!_sg_loadErrorImage) {
        _sg_loadErrorImage = UIImage.sg_imageFolderPath(@"sg_icon_loading_error", @"SGLoadResult");
    }
    return _sg_loadErrorImage;
}

@end

@implementation UIImage (SGResource)

+ (UIImage * _Nonnull (^)(NSString * _Nullable, NSString * _Nullable))sg_imageFolderPath {
    return ^(NSString *imageName, NSString *folderName) {
        return [UIImage imageWithContentsOfFile:NSBundle.sg_resourceFolderPath(imageName, folderName)];
    };
}

@end

@implementation NSBundle (SGResource)

+ (NSBundle *)sg_defaultBundle {
    static NSBundle *_bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:SGResource.class] pathForResource:@"SGResource" ofType:@"bundle"]];
    });
    return _bundle;
}

+ (NSString * _Nonnull (^)(NSString * _Nullable))sg_resourcePath {
    return ^(NSString *resourceName) {
        if (!resourceName || [resourceName isEqualToString:@""]) return @"";
        return [NSBundle.sg_defaultBundle.resourcePath stringByAppendingPathComponent:resourceName];
    };
}

+ (NSString * _Nonnull (^)(NSString * _Nullable, NSString * _Nullable))sg_resourceFolderPath {
    return ^(NSString *resourceName, NSString *folderName) {
        if (!folderName || [folderName isEqualToString:@""]) return self.sg_resourcePath(resourceName);
        return self.sg_resourcePath([folderName stringByAppendingPathComponent:resourceName]);
    };
}

@end
