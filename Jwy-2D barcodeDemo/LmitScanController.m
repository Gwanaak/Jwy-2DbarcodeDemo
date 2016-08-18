//
//  LmitScanController.m
//  Jwy-2D barcodeDemo
//
//  Created by XiaoMing on 16/8/18.
//  Copyright © 2016年 JWY. All rights reserved.
//

#import "LmitScanController.h"
#import <AVFoundation/AVFoundation.h>//
#import "successViewController.h"
#define ScreenHigh [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
@interface LmitScanController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (weak, nonatomic) IBOutlet UIImageView *backImgVIew;
@end

@implementation LmitScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor clearColor];
    self.title=@"扫描二维码";
    [self scanCamera];
}
- (void)scanCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //限制扫描范围
    //http://blog.csdn.net/lc_obj/article/details/41549469
    //默认值是CGRectMake(0, 0, 1, 1),按比例来
    [_output setRectOfInterest:CGRectMake((124)/ScreenHigh,((ScreenWidth-220)/2)/ScreenWidth,220/ScreenHigh,220/ScreenWidth)];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    // Start
    [_session startRunning];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"扫描完毕－－%@",stringValue);
        successViewController *successVC=[[successViewController alloc]init];
        successVC.qrStrig=stringValue;
        [self.navigationController pushViewController:successVC animated:YES];
        
    } else {
        NSLog(@"无扫描信息");
        return;
    }
    
}

@end
