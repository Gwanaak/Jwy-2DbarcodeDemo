//
//  ViewController.m
//  Jwy-2D barcodeDemo
//
//  Created by XiaoMing on 16/8/17.
//  Copyright © 2016年 JWY. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "Jwy2Dbarcode.h"
#import "ScanViewController.h"
#import "LmitScanController.h"
@interface ViewController ()<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UIImageView *barcodeImgview;
@property (nonatomic,strong)UIImage *saveImg;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"二维码";
    [self addLongTap];
}
//直接识别图片
- (IBAction)readQRcode:(id)sender {
    
    if (self.barcodeImgview.image) {
        
        NSString *qrstr=[Jwy2Dbarcode readQRCodeFromImage:self.barcodeImgview.image];
        [SVProgressHUD showSuccessWithStatus:qrstr];
    }else{
        [SVProgressHUD showErrorWithStatus:@"没图你识别个屁"];
    }

    
}
//去扫描二维码,限制范围
- (IBAction)scan2Dbarcode:(id)sender {
    
    LmitScanController *scanVC=[[LmitScanController alloc]init];
    [self.navigationController pushViewController:scanVC animated:YES];
    
}
//去扫描二维码
- (IBAction)read2Dbarcode:(id)sender {
    
    ScanViewController *scanVC=[[ScanViewController alloc]init];
    [self.navigationController pushViewController:scanVC animated:YES];
}
//创建二维码
- (IBAction)create2Dbarcode:(id)sender {
    
    [self.textfield resignFirstResponder];
    
    NSString *qrStr=self.textfield.text;
    //调用1:
    self.barcodeImgview=[Jwy2Dbarcode setShadowQRcodeView:self.barcodeImgview string:qrStr size:250.0f withRed:60.0f andGreen:74.0f andBlue:89.0f];
    
    //调用2:
    //self.barcodeImgview=[Jwy2Dbarcode setShadowQRcodeView:self.barcodeImgview string:qrStr size:250.0f fillColor:[UIColor purpleColor]];
    
    //调用3:
//    self.barcodeImgview.image = [Jwy2Dbarcode createQRimageString:qrStr size:250.f withRed:60.0f andGreen:74.0f andBlue:89.0f];
//    // set shadow
//    self.barcodeImgview.layer.shadowOffset = CGSizeMake(0, 2);
//    self.barcodeImgview.layer.shadowRadius = 2;
//    self.barcodeImgview.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.barcodeImgview.layer.shadowOpacity = 0.5;
}


#pragma mark---------添加手势---------
//添加长按手势保存二维码
-(void)addLongTap{
    [self.barcodeImgview setUserInteractionEnabled:YES];
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(imglongTapClick:)];
    [self.barcodeImgview addGestureRecognizer:longTap];
}
-(void)imglongTapClick:(UILongPressGestureRecognizer *)gesture

{
    
    if(gesture.state == UIGestureRecognizerStateBegan)
        
    {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      
                                      initWithTitle:@"保存图片"
                                      
                                      delegate:self
                                      
                                      cancelButtonTitle:@"取消"
                                      
                                      destructiveButtonTitle:nil
                                      
                                      otherButtonTitles:@"保存图片到手机",nil];
        
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        
        [actionSheet showInView:self.view];
        
        
        
        UIImageView *imgView = (UIImageView *)[gesture view];
        
        self.saveImg = imgView.image;
        
    }
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex

{
    
    if (buttonIndex == 0) {
        
        if (self.saveImg) {
            
             UIImageWriteToSavedPhotosAlbum(self.saveImg, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        }else{
            [SVProgressHUD showErrorWithStatus:@"没图你存个鬼"];
        }
       
        
    }
    
}
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo

{
    
    if (!error) {
        
        [SVProgressHUD showSuccessWithStatus:@"成功保存到相册"];
    }else{
        
        NSString * message = [error description];
        [SVProgressHUD showErrorWithStatus:message];
        
    }
    
}

@end
