//
//  HYMediator+QuickMarkActions.h
//  YunQiXin
//
//  Created by 沈红榜 on 2017/7/11.
//  Copyright © 2017年 沈红榜. All rights reserved.
//

#if __has_include(<HYMediator/HYMediator.h>)
#import <HYMediator/HYMediator.h>
#else
#import "HYMediator.h"
#endif

@interface HYMediator (QuickMarkActions)

- (UIViewController *)HYMediator_fetchQuickMarkControllerWithPopToRootVC:(BOOL)popToRoot animated:(BOOL)animated callback:(void(^)(NSString *content))handler;

- (NSString *)HYMediator_fetchQRStringFromImage:(UIImage *)image;

- (UIImage *)HYMediator_fetchQRImageWithContent:(NSString *)content;

@end
