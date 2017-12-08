//
//  YQQuickMarkViewController.h
//  YunQiXin
//
//  Created by 沈红榜 on 2017/7/11.
//  Copyright © 2017年 沈红榜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQQuickMarkViewController : UIViewController

- (instancetype)initWithCallback:(void(^)(NSString *content))handler;

@property (nonatomic, assign) BOOL popToRoot;
@property (nonatomic, assign) BOOL animated;


@end
