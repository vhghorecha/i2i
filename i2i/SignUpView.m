//
//  SignUpView.m
//  SDKTestApp
//
//  Created by Darshan on 29/07/16.
//  Copyright © 2016 inscripts. All rights reserved.
//

#import "SignUpView.h"
#import "CommonClass.h"
#import "LoginViewController.h"
#import <CometChatSDK/CometChat.h>

@interface SignUpView (){
    CometChat *cometChat;
}

@end

@implementation SignUpView

//UITextField
@synthesize txtUserName;
@synthesize txtDisPlayName;
@synthesize txtLink;
@synthesize txtPassword;
@synthesize txtConfirmPassword;

//UIButton
@synthesize btnSignUp;

@synthesize activityIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* Remove default Back button */
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-25"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    btnSignUp.layer.cornerRadius = 4.0f;
    
}

-(void)handleBackButton
{
    /* Pop view controller */
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - TextField FirstResponder

-(void)hideallKeyBoard
{
    if([txtUserName isFirstResponder]){
        [txtUserName resignFirstResponder];
    }
    if([txtDisPlayName isFirstResponder]){
        [txtDisPlayName resignFirstResponder];
    }
    if([txtLink isFirstResponder]){
        [txtLink resignFirstResponder];
    }
    if([txtPassword isFirstResponder]){
        [txtPassword resignFirstResponder];
    }
    if([txtConfirmPassword isFirstResponder]){
        [txtConfirmPassword resignFirstResponder];
    }
}

#pragma mark -
#pragma mark - TEXT FILED DELEGATE

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag;
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag+1];
    
    if (nextResponder)
    {
        [nextResponder becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint point;
    
    if (textField == txtUserName) {
        point = CGPointMake(0, 0);
    }else if (textField == txtDisPlayName){
        point = CGPointMake(0, 0);
    }else if (textField == txtLink){
        point = CGPointMake(0, 0);
    }else if (textField == txtPassword){
        point = CGPointMake(0, 0);
    }else if (textField == txtConfirmPassword){
        point = CGPointMake(0, 0);
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

-(BOOL)validateFormData
{
    NSString *strUserName   = [CommonClass trimString:txtUserName.text];
    NSString *strDIsPlayName    = [CommonClass trimString:txtDisPlayName.text];
    NSString *strLink      = [CommonClass trimString:txtLink.text];
    NSString *strePassword   = [CommonClass trimString:txtPassword.text];
    NSString *strCPassword        = [CommonClass trimString:txtConfirmPassword.text];
    
    if ([strUserName length] == 0) {
        [CommonClass showAlertWithTitle:@"Alert !" message:@"Please Enter UserName"];
        return NO;
    }
    if ([strDIsPlayName length] == 0) {
        [CommonClass showAlertWithTitle:@"Alert !" message:@"Please Enter DisPlayName"];
        return NO;
    }
    /*if ([strLink length] == 0) {
        [CommonClass showAlertWithTitle:@"Alert !" message:@"Please Enter Link"];
        return NO;
    }
    if ([strLink length] >= 1) {
        if(![CommonClass validateUrl:strLink]){
            [CommonClass showAlertWithTitle:@"Alert !" message:@"Please Enter Valid Link"];
            return NO;
        }
    }*/
    if ([strePassword length] == 0) {
        [CommonClass showAlertWithTitle:@"Alert !" message:@"Please Enter Password"];
        return NO;
    }
    if([strePassword length] < 6){
        [CommonClass showAlertWithTitle:@"Alert !" message:@"Password Must Be At Last 6 Digits"];
        return NO;
    }
    if([strCPassword length] == 0){
        [CommonClass showAlertWithTitle:@"Alert !" message:@"Please Enter Confirm Password"];
        return NO;
    }
    if(![strePassword isEqualToString:strCPassword]){
        [CommonClass showAlertWithTitle:@"Alert !" message:@"Both Password and Confirm Password not equal"];
        return NO;
    }
    
    return YES;
}

- (IBAction)onClickSignUpBtn:(id)sender {
    
    [self hideallKeyBoard];
    [self startLoader];
    if ([self validateFormData]) {
        
        NSLog(@"Create User");

        [[NSUserDefaults standardUserDefaults] setObject:SITE_URL forKey:@"websiteURL"];
        cometChat = [[CometChat alloc] initWithAPIKey:USER_KEYS];
        [cometChat setCometChatURL:SITE_URL];
        [cometChat createUser:txtUserName.text password:txtPassword.text link:txtLink.text avatar:@"" displayName:txtDisPlayName.text success:^(NSDictionary *response) {
            
            NSLog(@"SDK Log Create User Response : %@",response);
            LoginViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"];
            [self.navigationController pushViewController:viewController animated:YES];
            viewController = nil;
            
        } failure:^(NSError *error) {
            
            NSLog(@"SDK Log Create USEr Error : %@",error);
            
        }];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startLoader {
    
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
}

- (void)stopLoader {
    
    [activityIndicator setHidden:YES];
    [activityIndicator stopAnimating];
}

@end
