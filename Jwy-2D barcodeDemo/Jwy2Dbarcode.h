//
//  Jwy2Dbarcode.h
//  Jwy-2D barcodeDemo
//
//  Created by XiaoMing on 16/8/17.
//  Copyright © 2016年 JWY. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface Jwy2Dbarcode : NSObject
//生成二维码
+(UIImageView *)setShadowQRcodeView:(UIImageView *)qrcodeView string:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)color;
+(UIImageView *)setShadowQRcodeView:(UIImageView *)qrcodeView string:(NSString *)qrString size:(CGFloat)size withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;

+(UIImage *)createQRimageString:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)color;
+(UIImage *)createQRimageString:(NSString *)qrString size:(CGFloat)size withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;
//读取二维码
+(NSString *)readQRCodeFromImage:(UIImage *)image;

//带图片二维码
+(UIImageView *)setShadowQRcodeView:(UIImageView *)qrcodeView string:(NSString *)qrString size:(CGFloat)size withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue with:(UIImage *)headerImage;
@end
