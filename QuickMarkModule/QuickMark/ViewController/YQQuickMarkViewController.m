//
//  YQQuickMarkViewController.m
//  YunQiXin
//
//  Created by 沈红榜 on 2017/7/11.
//  Copyright © 2017年 沈红榜. All rights reserved.
//

#import "YQQuickMarkViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "YQQRTools.h"
#import "YQMaskView.h"

@interface YQQuickMarkViewController ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession          *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput  *videoOutput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *previewLayer;

@property (nonatomic, strong) YQMaskView    *topMaskView;
@property (nonatomic, strong) UILabel       *tip;

@property (nonatomic, strong) UIButton      *lightBtn;
@property (nonatomic, strong) UIButton      *lblBtn;

@property (nonatomic, strong) UIView        *netView;   //承载netLabel, 原因是只用netLabel时，文字不能在扫描框中心
@property (nonatomic, strong) UILabel       *netLabel;


@property (nonatomic, assign) BOOL          hadValue;   //对扫描内容作保护，如果扫描出内容置为true

@end

@implementation YQQuickMarkViewController {
    void(^_handler)(NSString *);
}

- (instancetype)initWithCallback:(void (^)(NSString *))handler {
    self = [super init];
    if (self) {
        _handler = handler;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"二维码";
    
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    if ([_session canAddInput:input]) {
        [_session addInput:input];
    }
    
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
    _videoOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    
    if ([_session canAddOutput:_videoOutput]) {
        [_session addOutput:_videoOutput];
    }
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:_previewLayer];
    
    CGRect scanRect = CGRectMake((CGRectGetWidth(self.view.frame) - 230) / 2., 166, 230,  230);
    
    _topMaskView = [[YQMaskView alloc] initWithClearFrame:scanRect];
    [self.view addSubview:_topMaskView];
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    
    [self.view addSubview:self.tip];
    _tip.frame = CGRectMake(0, CGRectGetMinY(scanRect) - 30 - _tip.font.lineHeight, width, _tip.font.lineHeight);
    
    [self.view addSubview:self.lightBtn];
    [self.view addSubview:self.lblBtn];
    _lightBtn.hidden = _lblBtn.hidden = true;
    
    
    [_lightBtn sizeToFit];
    _lightBtn.frame = CGRectMake((width - CGRectGetWidth(_lightBtn.frame)) / 2., CGRectGetMaxY(scanRect) + 20, CGRectGetWidth(_lightBtn.frame), CGRectGetHeight(_lightBtn.frame));
    
    [_lblBtn sizeToFit];
    _lblBtn.frame = CGRectMake((width - CGRectGetWidth(_lblBtn.frame)) / 2., CGRectGetMaxY(_lightBtn.frame) + 10, CGRectGetWidth(_lblBtn.frame), CGRectGetHeight(_lblBtn.frame));
    
    [self.view addSubview:self.netView];
    [self.netView addSubview:self.netLabel];
    _netView.hidden = true;
    _netLabel.frame = scanRect;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_session startRunning];
    _hadValue = false;  //开始扫描置为false
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_session stopRunning];
}

- (void)_clickedLightBtn:(UIButton *)btn {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [device lockForConfiguration:nil];
    
    if (device.torchActive) {
        device.torchMode = AVCaptureTorchModeOff;
        _lightBtn.selected = false;
        _lblBtn.selected = false;
    } else {
        device.torchMode = AVCaptureTorchModeOn;
        _lightBtn.selected = true;
        _lblBtn.selected = true;
    }
    [device unlockForConfiguration];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary *)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    [self _showOrHideLightBtn:brightnessValue];
    
    if (_hadValue) {
        return; //如果有扫描内容则只检测环境光
    }
    
    UIImage *image = [YQQRTools convertSampleBufferToImage:sampleBuffer];
    
    NSString *qrString = [YQQRTools fetchQRStringFromImage:image];
    
    if (qrString.length > 0) {
        [self _inMainThread:^{
            _hadValue = true;
            [_session stopRunning];
            [self _dealWithStringValue:qrString];
        }];
    }
}

#pragma mark - 私有方法
- (void)_dealWithStringValue:(NSString *)stringValue {

    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:_animated completion:^{
            if (_handler) {
                _handler(stringValue);
            }
        }];
    } else {
        if (_handler) {
            _handler(stringValue);
        }
        
        if (_popToRoot) {
            [self.navigationController popToRootViewControllerAnimated:_animated];
        } else {
            [self.navigationController popViewControllerAnimated:_animated];
        }
    }
}

- (void)_showOrHideLightBtn:(float)brightLevel {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!device.hasTorch) { //不支持手电，不显示按钮
        
        [self _inMainThread:^{
            
            _lightBtn.hidden = _lblBtn.hidden = true;
        }];
        return;
    }
    
    [self _inMainThread:^{
       
        if (device.torchActive) {
            if (_lightBtn.hidden) {
                _lightBtn.hidden = _lblBtn.hidden = false;
            }
        } else {
            _lightBtn.hidden = _lblBtn.hidden = brightLevel > 1;
        }
        
    }];
}

#pragma mark - Helps
- (CGRect)rectOfInterestByScanViewRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    CGFloat x = (height - CGRectGetHeight(rect)) / 2 / height;
    CGFloat y = (width - CGRectGetWidth(rect)) / 2 / width;
    
    CGFloat w = CGRectGetHeight(rect) / height;
    CGFloat h = CGRectGetWidth(rect) / width;
    
    return CGRectMake(x, y, w, h);
}

- (void)_inMainThread:(dispatch_block_t)callback {
    if ([NSThread currentThread].isMainThread) {
        callback();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback();
        });
    }
}

#pragma mark - getter
- (UILabel *)tip {
    if (!_tip) {
        _tip = [[UILabel alloc] initWithFrame:CGRectZero];
        _tip.textAlignment = NSTextAlignmentCenter;
        _tip.font = [UIFont systemFontOfSize:16];
        _tip.textColor = [UIColor whiteColor];
        _tip.text = @"请将取景框对准二维码";
    }
    return _tip;
}

- (UIButton *)lightBtn {
    if (!_lightBtn) {
        _lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lightBtn setImage:[UIImage imageNamed:@"light_image"] forState:UIControlStateNormal];
        [_lightBtn setImage:[UIImage imageNamed:@"light_image_close"] forState:UIControlStateSelected];
        [_lightBtn addTarget:self action:@selector(_clickedLightBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lightBtn;
}

- (UIButton *)lblBtn {
    if (!_lblBtn) {
        _lblBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lblBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateNormal];
        [_lblBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateSelected];
        [_lblBtn setTitle:@"轻触照亮" forState:UIControlStateNormal];
        [_lblBtn setTitle:@"轻触关闭" forState:UIControlStateSelected];
        _lblBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_lblBtn addTarget:self action:@selector(_clickedLightBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lblBtn;
}

- (UIView *)netView {
    if (!_netView) {
        _netView = [[UIView alloc] initWithFrame:self.view.bounds];
        _netView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    }
    return _netView;
}

- (UILabel *)netLabel {
    if (!_netLabel) {
        _netLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        _netLabel.numberOfLines = 0;
        _netLabel.textAlignment = NSTextAlignmentCenter;
        _netLabel.font = [UIFont systemFontOfSize:15];
        _netLabel.textColor = [UIColor whiteColor];
        _netLabel.text = @"当前网络不可用\n请检查网络设置";
    }
    return _netLabel;
}

- (BOOL)hidesBottomBarWhenPushed {
    return true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
