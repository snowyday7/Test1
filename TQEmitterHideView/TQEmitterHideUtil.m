//
//  TQEmitterHideUtil.m
//  TQEmitterHideView
//
//  Created by xtq on 15/9/17.
//  Copyright (c) 2015年 one. All rights reserved.
//

#import "TQEmitterHideUtil.h"

typedef void(^Completion)(BOOL finished);

@interface TQEmitterHideUtil()

@property (nonatomic, strong)CAShapeLayer *maskLayer;

@property (nonatomic, strong)UIView *view;

@property (nonatomic, strong)Completion completion;

@end

@implementation TQEmitterHideUtil

- (instancetype)init {
    self = [super init];
    if (self) {
        self.emitterExpandLength = 50;  //default is 50
        self.emitterColor = [UIColor darkGrayColor];
        self.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    }
    return self;
};

- (void)hideView:(UIView *)view duration:(NSTimeInterval)duration direction:(TQEmitterHideDirection)direction completion:(void (^)(BOOL finished))completion {
    self.completion = completion;
    self.view = view;
    view.userInteractionEnabled = NO;
    
    [self configMaskLayerWithViewFrame:view.frame duration:duration direction:direction];
    [self configEmitterLayerWithViewFrame:view.frame duration:duration direction:direction];
}

- (void)configMaskLayerWithViewFrame:(CGRect)viewFrame duration:(NSTimeInterval)duration direction:(TQEmitterHideDirection)direction {
    
    self.maskLayer.frame = CGRectMake(0, 0, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame));
    self.view.layer.mask = self.maskLayer;
    
    //if direction is TOP or Bottom,do animation with position.y ,Else,do animation with position.x
    CGFloat fromValue;
    CGFloat toValue;
    
    
    switch (direction) {
        case TQEmitterHideDirectionTop:{
            fromValue = CGRectGetMidY(self.maskLayer.frame);
            toValue = fromValue + CGRectGetHeight(viewFrame);
        }
            break;
        case TQEmitterHideDirectionBottom:{
            fromValue = CGRectGetMidY(self.maskLayer.frame);
            toValue = fromValue - CGRectGetHeight(viewFrame);
        }
            break;
        case TQEmitterHideDirectionLeft:{
            fromValue = CGRectGetMidX(self.maskLayer.frame);
            toValue = fromValue + CGRectGetWidth(viewFrame);
        }
            break;
        case TQEmitterHideDirectionRight:{
            fromValue = CGRectGetMidX(self.maskLayer.frame);
            toValue = fromValue - CGRectGetWidth(viewFrame);
        }
            break;
        default:
            break;
    }
    
    [self.maskLayer addAnimation:[self maskLayerAnimWithDuration:duration direction:direction FromValue:fromValue ToValue:toValue] forKey:@"maskLayerAnim"];
}

- (void)configEmitterLayerWithViewFrame:(CGRect)viewFrame duration:(NSTimeInterval)duration direction:(TQEmitterHideDirection)direction {
    
    //if direction is TOP or Bottom,do animation with position.y ,Else,do animation with position.x
    CGRect frame;
    CGFloat fromValue;
    CGFloat toValue;
    
    CAEmitterCell *cell = [[self.emitterLayer emitterCells] firstObject];

    switch (direction) {
        case TQEmitterHideDirectionTop:{
            frame = CGRectMake(CGRectGetMinX(viewFrame), CGRectGetMinY(viewFrame) - self.emitterExpandLength, CGRectGetWidth(viewFrame), self.emitterExpandLength);
            fromValue = CGRectGetMidY(frame);
            toValue = fromValue + CGRectGetHeight(viewFrame);
            cell.velocity = 0;
            cell.yAcceleration = -fabs(cell.yAcceleration);
        }
            break;
        case TQEmitterHideDirectionBottom:{
            frame = CGRectMake(CGRectGetMinX(viewFrame), CGRectGetMaxY(viewFrame), CGRectGetWidth(viewFrame), self.emitterExpandLength);
            fromValue = CGRectGetMidY(frame);
            toValue = fromValue - CGRectGetHeight(viewFrame);
            cell.velocity = 0;
            cell.yAcceleration = fabs(cell.yAcceleration);
        }
            break;
        case TQEmitterHideDirectionLeft:{
            frame = CGRectMake(CGRectGetMinX(viewFrame) - self.emitterExpandLength, CGRectGetMinY(viewFrame), self.emitterExpandLength, CGRectGetHeight(viewFrame));
            fromValue = CGRectGetMidX(frame);
            toValue = fromValue + CGRectGetWidth(viewFrame);
            cell.velocity = -fabs(cell.velocity);
            cell.yAcceleration = fabs(cell.yAcceleration);
        }
            break;
        case TQEmitterHideDirectionRight:{
            frame = CGRectMake(CGRectGetMaxX(viewFrame), CGRectGetMinY(viewFrame), self.emitterExpandLength, CGRectGetHeight(viewFrame));
            fromValue = CGRectGetMidX(frame);
            toValue = fromValue - CGRectGetWidth(viewFrame);
            cell.velocity = fabs(cell.velocity);
            cell.yAcceleration = fabs(cell.yAcceleration);
        }
            break;
        default:
            break;
    }
    
    self.emitterLayer.frame = frame;
    self.emitterLayer.emitterSize = self.emitterLayer.frame.size;
    self.emitterLayer.emitterPosition = CGPointMake(self.emitterLayer.frame.size.width / 2.0, self.emitterLayer.frame.size.height / 2.0);
    

    [self.emitterLayer addAnimation:[self emitterLayerAnimWithDuration:duration direction:direction FromValue:fromValue ToValue:toValue] forKey:@"emitterLayerAnim"];
    [self.view.superview.layer addSublayer:self.emitterLayer];
}

#pragma mark - Config Layers
- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.backgroundColor = [UIColor blackColor].CGColor;
        _maskLayer.shadowOpacity = 1;
        _maskLayer.shadowOffset = CGSizeMake(0, 0);
        _maskLayer.shadowRadius = 5;
    }
    return _maskLayer;
}

-(CAEmitterLayer *)emitterLayer{
    if (!_emitterLayer) {
        _emitterLayer = [CAEmitterLayer layer];
        _emitterLayer.emitterMode = kCAEmitterLayerUnordered;
        _emitterLayer.emitterShape = kCAEmitterLayerRectangle;
//        _emitterLayer.borderWidth = 1;
        
        CAEmitterCell *cell = [[CAEmitterCell alloc] init];
        cell.contents = (__bridge id)([self emitterContents].CGImage);
        cell.birthRate = 300;
        cell.lifetime = 5.0;
        
        cell.scale = 0.2;
        cell.scaleRange = 0.4;
        cell.color = self.emitterColor.CGColor;
        cell.alphaSpeed = -0.3;
        cell.velocity = 200;
        cell.velocityRange = cell.velocity / 2.0;
        cell.yAcceleration = 100.f;
        
        _emitterLayer.emitterCells = @[cell];
    }
    return _emitterLayer;
}

- (UIImage *)emitterContents {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    CGPoint p1 = CGPointMake(10, 0);
    CGPoint p2 = CGPointMake(0, 10);
    CGPoint p3 = CGPointMake(20, 10);
    
    
    UIBezierPath *bp = [UIBezierPath bezierPath];
    [bp moveToPoint:p1];
    [bp addLineToPoint:p2];
    [bp addLineToPoint:p3];
    
    shapeLayer.path = bp.CGPath;
    shapeLayer.shouldRasterize = YES;
    shapeLayer.fillColor = [UIColor whiteColor].CGColor;
    shapeLayer.strokeColor = [UIColor clearColor].CGColor;
    UIGraphicsBeginImageContext(CGSizeMake(20, 10));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [shapeLayer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - Animations
- (CABasicAnimation *)maskLayerAnimWithDuration:(CGFloat)duration direction:(TQEmitterHideDirection)direction FromValue:(CGFloat)fromValue ToValue:(CGFloat)toValue {
    NSString *keyPathName;
    if ((direction == TQEmitterHideDirectionLeft) || (direction == TQEmitterHideDirectionRight)) {
        keyPathName = @"position.x";
    }
    else {
        keyPathName = @"position.y";
    }
    CABasicAnimation *xPositionAnim = [CABasicAnimation animationWithKeyPath:keyPathName];
    xPositionAnim.duration = duration;
    xPositionAnim.fromValue = @(fromValue);
    xPositionAnim.toValue = @(toValue);
    xPositionAnim.fillMode = kCAFillModeForwards;
    xPositionAnim.removedOnCompletion = NO;
    xPositionAnim.timingFunction = self.timingFunction;
    return xPositionAnim;
}

- (CAAnimationGroup *)emitterLayerAnimWithDuration:(CGFloat)duration direction:(TQEmitterHideDirection)direction FromValue:(CGFloat)fromValue ToValue:(CGFloat)toValue {
    NSString *keyPathName;
    if ((direction == TQEmitterHideDirectionLeft) || (direction == TQEmitterHideDirectionRight)) {
        keyPathName = @"position.x";
    }
    else {
        keyPathName = @"position.y";
    }
    CABasicAnimation *ba2 = [CABasicAnimation animationWithKeyPath:keyPathName];
    ba2.duration = duration;
    ba2.fromValue = @(fromValue);
    ba2.toValue = @(toValue);
    ba2.delegate = self;
    ba2.timingFunction = self.timingFunction;
    ba2.removedOnCompletion = NO;

    
    CABasicAnimation *emitterOpacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    emitterOpacityAnim.fromValue = @1;
    emitterOpacityAnim.toValue = @0;
    emitterOpacityAnim.duration = duration;
    emitterOpacityAnim.removedOnCompletion = NO;

    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[ba2,emitterOpacityAnim];
    group.duration = duration;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.delegate = self;
    
    return group;
}

#pragma mark - AnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    self.view.alpha = 0;
    self.view.userInteractionEnabled = YES;
    self.view.layer.mask = nil;
    [self.maskLayer removeAnimationForKey:@"maskLayerAnim"];

    [self.emitterLayer removeFromSuperlayer];
    [self.emitterLayer removeAnimationForKey:@"emitterLayerAnim"];
    self.completion(YES);
}

- (void)dealloc {
    NSLog(@"dealloc");
    self.emitterLayer = nil;
    self.maskLayer = nil;
}

@end
