//
//  Target_QuickMark.h
//  YunQiXin
//
//  Created by 沈红榜 on 2017/7/11.
//  Copyright © 2017年 沈红榜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Target_QuickMark : NSObject

- (UIViewController *)Action_fetchQuickMarkControllerWithPopToRootVC:(NSDictionary *)param;

- (NSString *)Action_fetchQRStringFromImage:(NSDictionary *)param;
- (UIImage *)Action_fetchQRImageWithContent:(NSDictionary *)param;

@end
