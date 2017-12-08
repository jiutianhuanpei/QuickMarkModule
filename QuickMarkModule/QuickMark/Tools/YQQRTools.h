//
//  YQQRTools.h
//  YunQiXin
//
//  Created by 沈红榜 on 2017/7/11.
//  Copyright © 2017年 沈红榜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <CoreMedia/CoreMedia.h>

@interface YQQRTools : NSObject

+ (NSString *)fetchQRStringFromImage:(UIImage *)image;
+ (UIImage *)qrImageWithContent:(NSString *)content;

+ (UIImage *)convertSampleBufferToImage:(CMSampleBufferRef)sampleBuffer;

@end
