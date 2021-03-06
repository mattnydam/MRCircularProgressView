//
//  MRCircularProgressView.m
//  MRCircularProgressView
//
//  Created by Jose Luis Martinez de la Riva on 30/01/14.
//
//  Copyright (c) 2014 http://martinezdelariva.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE
//

#import "MRCircularProgressView.h"

@interface MRCircularProgressView()
@property (strong, nonatomic) CAShapeLayer *shapeLayer;
@property (assign, nonatomic) CGFloat currentProgress;
@property (assign, nonatomic) CGFloat lastProgress;
@property (assign, nonatomic) BOOL animated;
@property (assign, nonatomic) CFTimeInterval duration;
@end

@implementation MRCircularProgressView

- (void)awakeFromNib
{
    [self setUp];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    // Init variables
    self.delegate = nil;
    self.currentProgress = 0.0f;
    self.lastProgress = 0.0f;
    self.animated = YES;
    self.progressColor = [UIColor blueColor];
    self.duration = 0.5;
    self.progressArcWidth = 3.0f;
}

- (void)drawRect:(CGRect)rect
{
    // Outer circle
    CGRect newRect = ({
        CGRect insetRect = CGRectInset(rect, 1.5f, 1.5f);
        CGRect newRect = insetRect;
        newRect.size.width = MIN(CGRectGetMaxX(insetRect), CGRectGetMaxY(insetRect));
        newRect.size.height = newRect.size.width;
        newRect.origin.x = insetRect.origin.x + (CGRectGetWidth(insetRect) - CGRectGetWidth(newRect)) / 2;
        newRect.origin.y = insetRect.origin.y + (CGRectGetHeight(insetRect) - CGRectGetHeight(newRect)) / 2;
        newRect;
    });
    UIBezierPath *outerCircle = [UIBezierPath bezierPathWithOvalInRect:newRect];
    [self.progressColor setStroke];
    outerCircle.lineWidth = 1;
    [outerCircle stroke];
}

- (CGPathRef)progressPath
{
    // Offset
    CGFloat offset = - M_PI_2;
    
    // EndAngle
    CGFloat endAngle =  self.currentProgress * 2 * M_PI + offset;
    
    // Center
    CGRect rect = self.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));

    // Radius
    CGFloat radius = MIN(center.x, center.y) - self.progressArcWidth / 2;
    
    // Inner arc
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:center
                                                           radius:radius
                                                       startAngle:offset
                                                         endAngle:endAngle
                                                        clockwise:1];
    
    return arcPath.CGPath;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshShapeLayer];
}

#pragma mark - Getters methods

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.strokeColor = self.progressColor.CGColor;
        _shapeLayer.lineWidth = self.progressArcWidth;
        _shapeLayer.fillColor = nil;
        _shapeLayer.lineJoin = kCALineJoinBevel;
        [self.layer addSublayer:_shapeLayer];
    }
    
    return _shapeLayer;
}

#pragma mark - Private methods

- (void)refreshShapeLayer
{
    // Update path
    self.shapeLayer.path = [self progressPath];
    
    // Animation
    if (self.currentProgress != self.lastProgress && self.animated) {
        // From value
        CGFloat fromValue = (1 * self.lastProgress) / self.currentProgress;

        // Animation
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.delegate = self.delegate;
        pathAnimation.duration = self.duration;
        pathAnimation.fromValue = @(fromValue);
        pathAnimation.toValue = @(1.0f);
        [self.shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    }
    
    // Update lastProgress
    self.lastProgress = self.currentProgress;
}

#pragma mark - Public methods

- (void)setProgress:(CGFloat)progress animated:(BOOL)animate
{
    self.currentProgress = MAX(MIN(progress, 1.0f), 0.0f);
    self.animated = animate;
    
    [self setNeedsLayout];
}

- (void)setProgress:(CGFloat)progress duration:(CFTimeInterval)duration
{
    self.duration = duration;
    [self setProgress:progress animated:YES];
}

@end
