//
//  UIView+WM.h
//  bsbdj
//
//  Created by 邬志成 on 16/6/14.
//  Copyright © 2016年 邬志成. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WM)

@property (nonatomic,assign) CGFloat y;
@property (nonatomic,assign) CGFloat x;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGSize size;

@property (nonatomic,assign) CGFloat centerX;

@property (nonatomic,assign) CGFloat centerY;

-(void)setX:(CGFloat)x;
-(CGFloat)x;
-(void)setY:(CGFloat)y;
-(CGFloat)y;
-(void)setWidth:(CGFloat)width;
-(CGFloat)width;
-(void)setHeight:(CGFloat)height;
-(CGFloat)height;
-(void)setSize:(CGSize)size;
-(CGSize)size;
-(CGFloat)centerX;
-(void)setCenterX:(CGFloat)centerX;
-(CGFloat)centerY;
-(void)setCenterY:(CGFloat)centerY;

@end
