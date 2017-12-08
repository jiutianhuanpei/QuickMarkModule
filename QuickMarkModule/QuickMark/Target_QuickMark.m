//
//  Target_QuickMark.m
//  YunQiXin
//
//  Created by 沈红榜 on 2017/7/11.
//  Copyright © 2017年 沈红榜. All rights reserved.
//

#import "Target_QuickMark.h"
#import "YQQuickMarkViewController.h"
#import "YQQRTools.h"

@implementation Target_QuickMark

- (UIViewController *)Action_fetchQuickMarkControllerWithPopToRootVC:(NSDictionary *)param {
#if TARGET_IPHONE_SIMULATOR
    
    return nil;
#else
    YQQuickMarkViewController *VC = [[YQQuickMarkViewController alloc] initWithCallback:param[@"handler"]];
    VC.popToRoot = [param[@"pop"] boolValue];
    VC.animated = [param[@"animated"] boolValue];
    return VC;
#endif
}

- (NSString *)Action_fetchQRStringFromImage:(NSDictionary *)param {
    UIImage *image = param[@"img"];
    return [YQQRTools fetchQRStringFromImage:image];
}

- (UIImage *)Action_fetchQRImageWithContent:(NSDictionary *)param {
    NSString *content = param[@"text"];
    return [YQQRTools qrImageWithContent:content];
}


@end
