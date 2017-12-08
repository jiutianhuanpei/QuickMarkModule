//
//  HYMediator+QuickMarkActions.m
//  YunQiXin
//
//  Created by 沈红榜 on 2017/7/11.
//  Copyright © 2017年 沈红榜. All rights reserved.
//

#import "HYMediator+QuickMarkActions.h"

NSString *kTargetQuickMark = @"QuickMark";

@implementation HYMediator (QuickMarkActions)

- (UIViewController *)HYMediator_fetchQuickMarkControllerWithPopToRootVC:(BOOL)popToRoot animated:(BOOL)animated callback:(void (^)(NSString *))handler {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    param[@"pop"] = @(popToRoot);
    param[@"animated"] = @(animated);
    param[@"handler"] = handler;
    UIViewController *VC = [self performTarget:kTargetQuickMark action:@"fetchQuickMarkControllerWithPopToRootVC" params:param];
    return VC;
}

- (NSString *)HYMediator_fetchQRStringFromImage:(UIImage *)image {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    param[@"img"] = image;
    
    return [self performTarget:kTargetQuickMark action:@"fetchQRStringFromImage" params:param];
}

- (UIImage *)HYMediator_fetchQRImageWithContent:(NSString *)content {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    param[@"text"] = content;
    return [self performTarget:kTargetQuickMark action:@"fetchQRImageWithContent" params:param];
}

@end
