//
//  UIImage+WM.m
//  Pods
//
//  Created by roronoa on 2016/12/27.
//
//

#import "UIImage+WM.h"          //图片扩展

@implementation UIImage(wmda)

+(UIImage *)wm_imageWithColor:(UIColor *)aColor{
    return [UIImage wm_imageWithColor:aColor withFrame:CGRectMake(0, 0, 1, 1)];
}

+(UIImage *)wm_imageWithColor:(UIColor *)aColor withFrame:(CGRect)aFrame{
    UIGraphicsBeginImageContext(aFrame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [aColor CGColor]);
    CGContextFillRect(context, aFrame);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

//绘制带圆角的image
- (UIImage *)wm_roundedImage:(CGFloat)radius size:(CGSize)size {
    CGFloat scale = self.scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect imageRect = (CGRect){0,0,size};
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:imageRect cornerRadius:radius];
    CGContextAddPath(context, path.CGPath);
    CGContextEOClip(context);
    [self drawInRect:imageRect];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;

}

- (UIImage *)wm_roundCorner:(CGFloat)radius {
    return [self wm_roundedImage:radius size:self.size];
}

/** 变圆 */
- (UIImage *)wm_roundCorner {
    return [self wm_roundedImage:self.size.width size:self.size];
}

@end

//为SDK自带的 UIButton 类添加一些实用方法
@implementation UIButton (wmda)
- (void)wm_titleUnderIcon {
    [self wm_titleUnderIcon:0];
}

- (void)wm_titleUnderIcon:(CGFloat)paddingText {
    UIImage *image = [self imageForState:UIControlStateNormal];

    [self setContentEdgeInsets:UIEdgeInsetsZero];
    [self setImageEdgeInsets:UIEdgeInsetsZero];
    [self setTitleEdgeInsets:UIEdgeInsetsZero];

    [self.titleLabel sizeToFit];

    CGRect titleRect = [self titleRectForContentRect:self.bounds];

    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    CGFloat paddingV = (self.frame.size.height - paddingText - imageHeight - titleRect.size.height) / 2;
    CGFloat paddingH = (self.frame.size.width - imageWidth) / 2;

    [self setImageEdgeInsets:UIEdgeInsetsMake(paddingV, paddingH, paddingV + titleRect.size.height, paddingH)];

    CGRect imageRect = [self imageRectForContentRect:self.bounds];

    [self setTitleEdgeInsets:UIEdgeInsetsMake(imageRect.origin.y + imageRect.size.height + paddingText,
                                              0 - imageRect.size.width,
                                              imageRect.origin.y - paddingText,
                                              0)];
}


@end
