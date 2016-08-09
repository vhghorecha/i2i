//
//  SignUpView.h
//  SDKTestApp
//
//  Created by Darshan on 29/07/16.
//  Copyright © 2016 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "inscriptsAppDelegate.h"

@interface SignUpView : UIViewController

//UITextField
@property (nonatomic , strong) IBOutlet UITextField *txtUserName;
@property (nonatomic , strong) IBOutlet UITextField *txtDisPlayName;
@property (nonatomic , strong) IBOutlet UITextField *txtLink;
@property (nonatomic , strong) IBOutlet UITextField *txtPassword;
@property (nonatomic , strong) IBOutlet UITextField *txtConfirmPassword;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

//UIButton
@property (nonatomic , strong) IBOutlet UIButton *btnSignUp;

@end
