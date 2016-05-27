//
//  TQEmitterHideUtil.h
//  TQEmitterHideView
//
//  Created by xtq on 15/9/17.
//  Copyright (c) 2015年 one. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TQEmitterHideDirection) {
    TQEmitterHideDirectionTop = 0,      //From Top
    TQEmitterHideDirectionBottom,       //From Bottom
    TQEmitterHideDirectionLeft,         //From Left
    TQEmitterHideDirectionRight,        //From Right
};


@interface TQEmitterHideUtil : NSObject

@property (nonatomic, assign)CGFloat emitterExpandLength;   //default is 50

@property (nonatomic, assign)UIColor *emitterColor;         //default is darkGrayColor

@property(strong) CAMediaTimingFunction *timingFunction;    //default is Default

@property (nonatomic, strong)CAEmitterLayer *emitterLayer;

- (void)hideView:(UIView *)view duration:(NSTimeInterval)duration direction:(TQEmitterHideDirection)direction completion:(void (^)(BOOL finished))completion;

@end
