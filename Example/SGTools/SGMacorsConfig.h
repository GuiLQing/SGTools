//
//  SGMacorsConfig.h
//  SGTools
//
//  Created by lg on 2019/7/26.
//  Copyright © 2019 GuiLQing. All rights reserved.
//

#ifndef SGMacorsConfig_h
#define SGMacorsConfig_h

//发布版本不输出调试信息
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#define SGLog(format, ...) NSLog((@"文件名 : %s\n" "函数名 : %s  " "行号 : %d\n" format), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define NSLog(...) {}
#define SGLog(...) {}
#endif

static inline BOOL SG_IS_IPHONE_X() {
    BOOL iPhoneX = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneX;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneX = YES;
        }
    }
    return iPhoneX;
}

/** 处理带有中文的图片链接utf8编码，使用了正则表达式判断，如果没有中文则原样返回 */
static inline NSString * _Nonnull SG_HandleImageUrl(NSString * _Nonnull urlString) {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\u4e00-\u9fa5]" options:NSRegularExpressionCaseInsensitive error:&error];
    if (!error) {
        NSArray *resultArray = [regex matchesInString:urlString options:0 range:NSMakeRange(0, urlString.length)];
        resultArray = [resultArray reverseObjectEnumerator].allObjects;
        for (NSTextCheckingResult *result in resultArray) {
            NSString *resultString = [urlString substringWithRange:result.range];
            urlString = [urlString stringByReplacingCharactersInRange:result.range withString:[resultString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        }
    }
    return urlString;
}

static inline void SG_GetVideoMIMITypeFromNSULRSession(NSURL * _Nonnull url, void (^ _Nullable callback)(NSString * _Nonnull MIMEType)) {
    [[NSURLSession.sharedSession downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (callback) callback(response.MIMEType);
    }] resume];
}

#pragma mark - ColorMacors

static inline UIColor * _Nonnull SG_RGBA(NSInteger r, NSInteger g, NSInteger b, CGFloat a) {
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a];
}

static inline UIColor * _Nonnull SG_RGB(NSInteger r, NSInteger g, NSInteger b) {
    return SG_RGBA(r, g, b, 1.0f);
}

static inline UIColor * _Nonnull SG_HexColorA(NSInteger c, CGFloat a) {
    return [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:a];
}

static inline UIColor * _Nonnull SG_HexColor(NSInteger c) {
    return SG_HexColorA(c, 1.0f);
}

static inline UIColor * _Nonnull SG_HexColorString(NSString * _Nonnull rgbValue) {
    rgbValue = [rgbValue stringByReplacingOccurrencesOfString:@"#" withString:@""];
    return [UIColor colorWithRed:((float)((strtoul(rgbValue.UTF8String, 0, 16) & 0xFF0000) >> 16))/255.0 green:((float)((strtoul((rgbValue).UTF8String, 0, 16) & 0xFF00) >> 8))/255.0 blue:((float)(strtoul((rgbValue).UTF8String, 0, 16) & 0xFF))/255.0 alpha:1.0];
}

#pragma mark - FontMacors

static inline UIFont * _Nonnull SG_FontSize(CGFloat size) {
    return [UIFont systemFontOfSize:size];
}

#pragma mark - PathMacors

static inline NSString * _Nonnull SG_AppendPathComponent(NSString * _Nonnull path, NSString * _Nullable lastPathComponent) {
    if (lastPathComponent && ![lastPathComponent isEqualToString:@""]) {
        if ([lastPathComponent hasPrefix:@"/"]) {
            path = [path stringByAppendingString:lastPathComponent];
        } else {
            path = [path stringByAppendingPathComponent:lastPathComponent];
        }
    }
    return path;
}

static inline NSString * _Nonnull SG_PathTemp(NSString * _Nullable lastPathComponent) {
    NSString *pathTemp = NSTemporaryDirectory();
    return SG_AppendPathComponent(pathTemp, lastPathComponent);
}

static inline NSString * _Nonnull SG_PathDocument(NSString * _Nullable lastPathComponent) {
    NSString *pathDocument = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return SG_AppendPathComponent(pathDocument, lastPathComponent);
}

static inline NSString * _Nonnull SG_PathCache(NSString * _Nullable lastPathComponent) {
    NSString *pathCache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    return SG_AppendPathComponent(pathCache, lastPathComponent);
}

static inline NSString * _Nonnull SG_PathLibraryAppend(NSString * _Nullable lastPathComponent) {
    NSString *pathLibrary = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    return SG_AppendPathComponent(pathLibrary, lastPathComponent);
}

#endif /* SGMacorsConfig_h */
