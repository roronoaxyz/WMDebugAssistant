//
//  UIImage+WM.h
//  Pods
//
//  Created by roronoa on 2016/12/27.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//为SDK自带的 UIImage 类添加一些实用方法
@interface UIImage(wmda)


/** 纯色 **/
+(UIImage *)wm_imageWithColor:(UIColor *)aColor;
+(UIImage *)wm_imageWithColor:(UIColor *)aColor withFrame:(CGRect)aFrame;

/** 变圆 */
- (UIImage *)wm_roundCorner;
@end

//为SDK自带的 UIButton 类添加一些实用方法
@interface UIButton (wmda)

//文字在图标下
- (void)wm_titleUnderIcon;
- (void)wm_titleUnderIcon:(CGFloat)paddingText;

@end
