//
//  YQQRTools.m
//  YunQiXin
//
//  Created by 沈红榜 on 2017/7/11.
//  Copyright © 2017年 沈红榜. All rights reserved.
//

#import "YQQRTools.h"

@implementation YQQRTools

+ (NSString *)fetchQRStringFromImage:(UIImage *)image {
    
    if (!image) {
        return nil;
    }
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
    
    CIImage *ciImg = [CIImage imageWithCGImage:image.CGImage];

    NSArray *array = [detector featuresInImage:ciImg];
    
    if (array.count > 0) {
        CIQRCodeFeature *feature = array[0];
        return feature.messageString;
    }
    
    return nil;
}

+ (UIImage *)qrImageWithContent:(NSString *)content {
    return [self _qrImageWithContent:content size:300];
}

+ (UIImage *)_qrImageWithContent:(NSString *)content size:(CGFloat)size {
    if (content.length == 0) {
        return nil;
    }
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    NSData *inputData = [content dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:inputData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CIImage *image = filter.outputImage;
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

+ (UIImage *)convertSampleBufferToImage:(CMSampleBufferRef)sampleBuffer {
    //制作 CVImageBufferRef
    CVImageBufferRef buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    //从 CVImageBufferRef 取得影像的细部信息
    size_t width, height, bytesPerRow;
    uint8_t *base = CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    //利用取得影像细部信息格式化 CGContextRef
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    //透过 CGImageRef 将 CGContextRef 转换成 UIImage
    
    
    CGImageRef cgImage = CGBitmapContextCreateImage(cgContext);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    return image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
