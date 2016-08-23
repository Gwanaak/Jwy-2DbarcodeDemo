//
//  Jwy2Dbarcode.m
//  Jwy-2D barcodeDemo
//
//  Created by XiaoMing on 16/8/17.
//  Copyright © 2016年 JWY. All rights reserved.
//

#import "Jwy2Dbarcode.h"

@implementation Jwy2Dbarcode

#pragma mark 读取图片二维码
/**
 *  读取图片中二维码信息
 *
 *  @param image 图片
 *
 *  @return 二维码内容
 */
+(NSString *)readQRCodeFromImage:(UIImage *)image{
    NSData *data = UIImagePNGRepresentation(image);
    CIImage *ciimage = [CIImage imageWithData:data];
    if (ciimage) {
        CIDetector *qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}] options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        NSArray *resultArr = [qrDetector featuresInImage:ciimage];
        if (resultArr.count >0) {
            CIFeature *feature = resultArr[0];
            CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
            NSString *result = qrFeature.messageString;
            
            return result;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

#pragma mark －－－生成二维码－－－
/**
 *  生成二维码图片
 *
 *  @param qrString  二维码内容
 *  @param size 图片size（正方形）
 *  @param color     填充色
 *
 *  @return  二维码图片
 */
+(UIImage *)createQRimageString:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)color{
    CIImage *ciimage = [self createQRForString:qrString];
    UIImage *qrcodeImage = [self createNonInterpolatedUIImageFormCIImage:ciimage withSize:size];
    if (color) {
        CGFloat R, G, B;
        
        CGColorRef colorRef = [color CGColor];
        long numComponents = CGColorGetNumberOfComponents(colorRef);
        
        if (numComponents == 4)
        {
            const CGFloat *components = CGColorGetComponents(colorRef);
            R = components[0];
            G = components[1];
            B = components[2];
        }
        
        UIImage *customQrcodeImage = [self imageBlackToTransparent:qrcodeImage withRed:R andGreen:G andBlue:B];
        return customQrcodeImage;
    }
    
    return qrcodeImage;
    
}
+(UIImage *)createQRimageString:(NSString *)qrString size:(CGFloat)size withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    
    CIImage *ciimage = [self createQRForString:qrString];
    UIImage *qrcodeImage = [self createNonInterpolatedUIImageFormCIImage:ciimage withSize:size];
    UIImage *customQrcodeImage = [self imageBlackToTransparent:qrcodeImage withRed:red andGreen:green andBlue:blue];
    return customQrcodeImage;
    
}




#pragma mark - QRCodeGenerator
+ (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // Send the image back
    return qrFilter.outputImage;
}
#pragma mark - InterpolatedUIImage
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // create a bitmap image that we'll draw into a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
#pragma mark - imageToTransparent
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}


#pragma mark －－－生成二维码的UIImageView带阴影效果－－－
//没必要封装这两个方法,只是懒，感觉这个阴影刚刚好
+(UIImageView *)setShadowQRcodeView:(UIImageView *)qrcodeView string:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)color{
    
    qrcodeView.image = [self createQRimageString:qrString size:size fillColor:color];
    // set shadow
    qrcodeView.layer.shadowOffset = CGSizeMake(0, 2);
    qrcodeView.layer.shadowRadius = 2;
    qrcodeView.layer.shadowColor = [UIColor blackColor].CGColor;
    qrcodeView.layer.shadowOpacity = 0.5;
    return qrcodeView;
}
+(UIImageView *)setShadowQRcodeView:(UIImageView *)qrcodeView string:(NSString *)qrString size:(CGFloat)size withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    qrcodeView.image = [self createQRimageString:qrString size:size withRed:red andGreen:green andBlue:blue];
    // set shadow
    qrcodeView.layer.shadowOffset = CGSizeMake(0, 2);
    qrcodeView.layer.shadowRadius = 2;
    qrcodeView.layer.shadowColor = [UIColor blackColor].CGColor;
    qrcodeView.layer.shadowOpacity = 0.5;
    return qrcodeView;
}
//带图片二维码
+(UIImageView *)setShadowQRcodeView:(UIImageView *)qrcodeView string:(NSString *)qrString size:(CGFloat)size withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue with:(UIImage *)headerImage{
    UIImage *barcodeImg= [self createQRimageString:qrString size:size withRed:red andGreen:green andBlue:blue];
    qrcodeView.image=[self imageInsertedImage:barcodeImg insertImage:headerImage radius:10.0f];
    // set shadow
    qrcodeView.layer.shadowOffset = CGSizeMake(0, 2);
    qrcodeView.layer.shadowRadius = 2;
    qrcodeView.layer.shadowColor = [UIColor blackColor].CGColor;
    qrcodeView.layer.shadowOpacity = 0.5;
    return qrcodeView;
}

#pragma mark －－－在二维码原图中心位置插入圆角图像－－－
//在二维码原图中心位置插入圆角图像
+ (UIImage *)imageInsertedImage: (UIImage *)originImage insertImage: (UIImage *)insertImage radius: (CGFloat)radius{
    
    if (!insertImage) { return originImage; }
    
        //画圆角
        insertImage = [self imageOfRoundRectWithImage: insertImage size: insertImage.size radius: radius];
        
        UIImage * whiteBG = [UIImage imageNamed: @"whiteBG"];
        
        whiteBG = [self imageOfRoundRectWithImage: whiteBG size: whiteBG.size radius: radius];
        
        //白色边缘宽度
        
        const CGFloat whiteSize = 2.f;
        
        CGSize brinkSize = CGSizeMake(originImage.size.width / 4, originImage.size.height / 4);
        
        CGFloat brinkX = (originImage.size.width - brinkSize.width) * 0.5;
        
        CGFloat brinkY = (originImage.size.height - brinkSize.height) * 0.5;
        
        CGSize imageSize = CGSizeMake(brinkSize.width - 2 * whiteSize, brinkSize.height - 2 * whiteSize);
        
        CGFloat imageX = brinkX + whiteSize;
        
        CGFloat imageY = brinkY + whiteSize;
        
        UIGraphicsBeginImageContext(originImage.size);
        
        [originImage drawInRect: (CGRect){ 0, 0, (originImage.size) }];
        
        [whiteBG drawInRect: (CGRect){ brinkX, brinkY, (brinkSize) }];
        
        [insertImage drawInRect: (CGRect){ imageX, imageY, (imageSize) }];
        
        UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return resultImage;
    
}
+ (UIImage *)imageOfRoundRectWithImage: (UIImage *)image size: (CGSize)size radius: (CGFloat)radius

{
    
    if (!image) { return nil; }
    
        const CGFloat width = size.width;

        const CGFloat height = size.height;

        radius = MAX(5.f, radius);

        radius = MIN(10.f, radius);

        UIImage * img = image;

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);

        CGRect rect = CGRectMake(0, 0, width, height);

        //绘制圆角

        CGContextBeginPath(context);
    
        addRoundRectToPath(context, rect, radius, img.CGImage);

        CGImageRef imageMasked = CGBitmapContextCreateImage(context);

        img = [UIImage imageWithCGImage: imageMasked];

        CGContextRelease(context);

        CGColorSpaceRelease(colorSpace);

        CGImageRelease(imageMasked);

        return img;
    
}
/**
 *  给上下文添加圆角蒙版
 */
void addRoundRectToPath(CGContextRef context, CGRect rect, float radius, CGImageRef image)
{
    float width, height;
    if (radius == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    width = CGRectGetWidth(rect);
    height = CGRectGetHeight(rect);
    
    //裁剪路径
    CGContextMoveToPoint(context, width, height / 2);
    CGContextAddArcToPoint(context, width, height, width / 2, height, radius);
    CGContextAddArcToPoint(context, 0, height, 0, height / 2, radius);
    CGContextAddArcToPoint(context, 0, 0, width / 2, 0, radius);
    CGContextAddArcToPoint(context, width, 0, width, height / 2, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRestoreGState(context);
}


@end
