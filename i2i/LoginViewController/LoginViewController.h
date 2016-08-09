//
//  LoginViewController.h
//  SDKTestApp
//
//  Created by Inscripts on 18/06/15.
//  Copyright (c) 2015 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CometChatSDK/CometChat.h>
#import "HttpWrapper.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate , HttpWrapperDelegate>
{
    HttpWrapper *httpAuth;
}
@property (weak, nonatomic) IBOutlet UIView *loginOptionsView;
@property (weak, nonatomic) IBOutlet UIView *usernameLoginView;


@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property IBOutletCollection(UIButton) NSArray *controlButtons;
@property (weak, nonatomic) IBOutlet UILabel *loginWithLabel;

- (IBAction)handleOptionClick:(id)sender;
- (IBAction)login:(id)sender;
@end
