//
//  ViewController.m
//  NewSelectedView
//
//  Created by wangzheng on 17/8/23.
//  Copyright © 2017年 WZheng. All rights reserved.
//

#import "ViewController.h"
#import "WZDownSelectedView.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet WZDownSelectedView *typeNew;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.typeNew.limitcount = 4;
    self.typeNew.listArray = @[@"全部",@"编辑中", @"未整改", @"整改中", @"已整改", @"已验收"];
    self.typeNew.textAlignment = NSTextAlignmentLeft;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
