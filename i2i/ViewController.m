//
//  ViewController.m
//  SDKTestApp
//
//  Created by Darshan on 29/07/16.
//  Copyright © 2016 inscripts. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize btnContinue;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    btnContinue.layer.cornerRadius = 4.0f;
    btnContinue.layer.borderColor = [UIColor whiteColor].CGColor;
    btnContinue.layer.borderWidth = 1.0f;    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
