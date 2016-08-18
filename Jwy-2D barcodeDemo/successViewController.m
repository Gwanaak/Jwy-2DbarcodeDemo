//
//  successViewController.m
//  LCQRcodeScan
//
//  Created by XiaoMing on 16/8/17.
//  Copyright © 2016年 刘通超. All rights reserved.
//

#import "successViewController.h"

@interface successViewController ()

@end

@implementation successViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor cyanColor];
    UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem=leftItem;
    UILabel *label=[[UILabel alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:label];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=self.qrStrig;
}
-(void)goBack{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
