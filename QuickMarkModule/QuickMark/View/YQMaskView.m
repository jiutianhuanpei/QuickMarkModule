//
//  YQMaskView.m
//  YunQiXin
//
//  Created by 沈红榜 on 2017/9/12.
//  Copyright © 2017年 沈红榜. All rights reserved.
//

#import "YQMaskView.h"

@interface YQMaskView ()

@property (nonatomic, strong) UIImageView   *imgView;
@property (nonatomic, strong) UIImageView   *line;

@end

@implementation YQMaskView {
    CGRect  _clearFrame;
}

- (instancetype)initWithClearFrame:(CGRect)frame {
    CGRect selfFrame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:selfFrame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = false;
        _clearFrame = frame;
        
        [self addSubview:self.imgView];
        _imgView.frame = frame;
        
        [_imgView addSubview:self.line];
        _line.frame = [self _lineViewInitialFrame];
        [self _moveLine];
    }
    return self;
}

- (void)_moveLine {
    
    _line.frame = [self _lineViewInitialFrame];
    [UIView animateWithDuration:2.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _line.frame = CGRectMake(CGRectGetMinX(_line.frame), CGRectGetHeight(_clearFrame) - CGRectGetHeight(_line.frame), CGRectGetWidth(_line.frame), CGRectGetHeight(_line.frame));
    } completion:^(BOOL finished) {
        [self _moveLine];
    }];
}

- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *bigPath = [UIBezierPath bezierPathWithRect:rect];
    
    UIBezierPath *smallPath = [UIBezierPath bezierPathWithRect:_clearFrame];
    
    [bigPath appendPath:smallPath];
    bigPath.usesEvenOddFillRule = true;
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = bigPath.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.fillColor = [UIColor blackColor].CGColor;
    layer.opacity = 0.7;
    [self.layer addSublayer:layer];
}

- (CGRect)_lineViewInitialFrame {
    [_line sizeToFit];
    
    CGFloat hs = 0;
    CGFloat w = CGRectGetWidth(_clearFrame) - 2. * hs;
    
    CGFloat h = w * CGRectGetHeight(_line.frame) / CGRectGetWidth(_line.frame);
    return CGRectMake(hs, 0, w, h);
}

#pragma mark - getter
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"finder_image"]];
    }
    return _imgView;
}

- (UIImageView *)line {
    if (!_line) {
        _line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanline_image"]];
    }
    return _line;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
