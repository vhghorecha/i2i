//
//  LoginViewController.m
//  SDKTestApp
//
//  Created by Inscripts on 18/06/15.
//  Copyright (c) 2015 inscripts. All rights reserved.
//

#import "LoginViewController.h"
#import "NativeKeys.h"
#import "MainViewController.h"
#import <CometChatSDK/CometChatChatroom.h>
#import <CometChatSDK/CometChat.h>
#import "inscriptsAppDelegate.h"
#import "EditProfile.h"

@interface LoginViewController () {
    
    CometChat *cometChat;
    BOOL loginFlag;
    UIBarButtonItem *backButton;
}

@end

@implementation LoginViewController {
    
}

@synthesize loginOptionsView,usernameLoginView,usernameTextField,passwordTextField;
@synthesize activityIndicator;
@synthesize controlButtons;
@synthesize loginWithLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize Variables
    cometChat = [[CometChat alloc] initWithAPIKey:USER_KEYS];
    [cometChat setCometChatURL:SITE_URL];
    
    loginFlag = NO;
    [activityIndicator setHidden:YES];
    
    //Navigation Bar settings
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    /* Remove default Back button */
    self.navigationItem.hidesBackButton = YES;
    backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-25"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBackButton)];
    
    //Settings for buttons
    for (UIButton *button in controlButtons) {
        
        button.layer.cornerRadius = 5; // this value vary as per your desire
        button.clipsToBounds = YES;
    }
    
    //Set Development Mode to YES to log request and response params.
    [CometChat setDevelopmentMode:YES];
    
    NSLog(@"SDK Version is %@",[CometChat getSDKVersion]);
    
    //Check if user has previously logged-in. If LOGIN_DETAILS is found in NSUserDefaults then the user is logged-in.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_DETAILS]) {
        
        //You have to always call CometChat login before subscribing
        
        loginFlag = YES;
        
        
        // cometChat = [[CometChat alloc] initWithAPIKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"apiKey"]];
        
        switch ([[[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_DETAILS] objectAtIndex:0] integerValue]) {
                
            case 1: {
                
                
                
                //Login using UserID
                [cometChat loginWithURL:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"websiteURL"]] userID:[NSString stringWithFormat:@"%@",[[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_DETAILS] objectAtIndex:1]] success:^(NSDictionary *response) {
                    
                    NSLog(@"SDK log : UserID Login Success %@",response);
                    
                    [self handleLogin];
                    
                } failure:^(NSError *error) {
                    
                    NSLog(@"SDK log : UserID Login Error%@",error);
                    [self handleLoginError:@[@1,error]];
                    
                }];
                
            }
                break;
                
            case 2: {
                
                //Login using Username & Password
                [cometChat logoutWithSuccess:^(NSDictionary *response) {
                    [cometChat loginWithURL:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"websiteURL"]] username:[NSString stringWithFormat:@"%@",[[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_DETAILS] objectAtIndex:1]] password:[NSString stringWithFormat:@"%@",[[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_DETAILS] objectAtIndex:2]] success:^(NSDictionary *response) {
                        
                        NSLog(@"SDK log : Username/Password Login Success %@",response);
                        
                        [self handleLogin];
                        
                        
                    } failure:^(NSError *error) {
                        NSLog(@"SDK log : Username/Password Login Error%@",error);
                        [self handleLoginError:@[@1,error]];
                        
                    }];
                } failure:^(NSError *error) {
                    NSLog(@"Error");
                }];
                
            }
                break;
                
            case 3: {
                //Guest Login
                
                /* You don't need to call login again if you have logged in as guest, because if you call login again with guest then you will be recognized as different user by CometChat.
                 This is an exception for Guest Login */
                
                [self handleLogin];
            }
                break;
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationItem.title = @"Login View";
    
    if (loginFlag) {
        
        [self.navigationController setNavigationBarHidden:YES];
        [usernameLoginView setHidden:YES];
        [loginOptionsView setHidden:NO];
        [loginWithLabel setHidden:YES];
        
        [self startLoader];
        
    } else {
        
        [self.navigationController setNavigationBarHidden:NO];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        
        [usernameLoginView setHidden:YES];
        [loginOptionsView setHidden:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    //LoginViewController will disappear only when login is successfull. Thus, reset the flag
    loginFlag = NO;
}
#pragma mark - Private Methods

- (void)handleBackButton {
    
    if (loginOptionsView.hidden == NO) {
        
        [loginOptionsView setHidden:YES];
        [loginWithLabel setHidden:YES];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        
    } else if (usernameLoginView.hidden == NO) {
        
        [usernameLoginView setHidden:YES];
        [loginOptionsView setHidden:NO];
        [loginWithLabel setHidden:NO];
        
    }
}

- (void)showAlertWithTitle:(NSString *)title messageString:(NSString *)message {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    alertView = nil;
    
    
}

- (void)handleLogin {
    
    /* Handle Login success event in this block */
    [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"Login Success"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
    
    MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainviewcontroller"];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
    
    [self stopLoader];

}

- (void)handleLoginError:(NSArray *)array {
    
    [self stopLoader];
    
    [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"Login Failure"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_DETAILS];
    
    NSString *message = @"Error message";
    
    switch ([[array objectAtIndex:1] code]) {
        case 10:
            message = [NSString stringWithFormat:@"Please check your internet connection"];
            break;
        case 11:
            message = [NSString stringWithFormat:@"Error in connection"];
            break;
        case 20:
            message = [NSString stringWithFormat:@"Please check username or password"];
            break;
        case 21:
            message = [NSString stringWithFormat:@"Invalid user details"];
            break;
        case 22:
            message = [NSString stringWithFormat:@"Invalid URL"];
            break;
        case 23:
            message = [NSString stringWithFormat:@"i2i needs to be upgraded on the site"];
        case 24:
            message = [NSString stringWithFormat:@"Invalid credentials OR Server not configured. Please contact the administrator"];
            break;
        default:
            message = [NSString stringWithFormat:@"%@",[[[array objectAtIndex:1] userInfo] objectForKey:NSLocalizedDescriptionKey]];
            break;
    }
    
    [self showAlertWithTitle:@"" messageString:message];
    
    if ([[array objectAtIndex:0] isEqualToNumber:@1]) {
        [self.navigationController setNavigationBarHidden:NO];
        
        [usernameLoginView setHidden:YES];
        [loginOptionsView setHidden:YES];
        [loginWithLabel setHidden:YES];
    }
    
    message = nil;
}

- (void)startLoader {
    
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
}

- (void)stopLoader {
    
    [activityIndicator setHidden:YES];
    [activityIndicator stopAnimating];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - IBAction Methods

- (IBAction)login:(id)sender {
   
    [self textFieldShouldReturn:passwordTextField];
            
            if ([usernameTextField.text isEqualToString:@""]) {
                
                [self showAlertWithTitle:@"" messageString:@"Username cannot be empty"];
                return;
                
            } else if ([passwordTextField.text isEqualToString:@""]) {
                
                [self showAlertWithTitle:@"" messageString:@"Password cannot be empty"];
                return;
                
            } else {
                //[self authUserWith:usernameTextField.text andPwd:passwordTextField.text];
                
                
                [self startLoader];
                
                
                [cometChat loginWithURL:SITE_URL username:usernameTextField.text password:passwordTextField.text success:^(NSDictionary *response) {
                    [[NSUserDefaults standardUserDefaults] setObject:SITE_URL forKey:@"websiteURL"];
                    
                    NSLog(@"SDK log : Username/Password Login Success %@",response);
                    
                    [self handleLogin];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:@[LOGIN_TYPE_USERNAME,usernameTextField.text,passwordTextField.text] forKey:LOGIN_DETAILS];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    CometChatChatroom *cometChatChatroom = [[CometChatChatroom alloc] init];
                    
                    [cometChatChatroom subscribeToChatroomWithMode:YES
                     
                                         onChatroomMessageReceived:^(NSDictionary *response) {
                                             /* Chatroom messages will be recieved in this callback */
                                             NSLog(@"SDK log : chatroom onChatroomMessageReceived %@",response);
                                             
                                         } onActionMessageReceived:^(NSDictionary *response) {
                                             /* Callback block for actions in chatroom */
                                             
                                             NSLog(@"SDK log : on Action Message received %@",response);
                                             
                                         }
                                           onChatroomsListReceived:^(NSDictionary *response) {
                                               
                                               /* Chatrooms list will be received here */
                                               NSLog(@"SDK log : chatroom chatroomsListReceived %@",response);
                                               
                                               
                                           } onChatroomMembersListReceived:^(NSDictionary *response) {
                                               
                                               /* Chatrooms list will be received here */
                                               NSLog(@"SDK log : chatroom ChatroomMembersListReceived %@",response);
                                               
                                               
                                           } onAVChatMessageReceived:^(NSDictionary *response) {
                                               NSLog(@"SDK log : AudioVideo Group Conference message received = %@",response);
                                               
                                               
                                               
                                           } failure:^(NSError *error) {
                                               NSLog(@"SDK log : chatroom subscribe error %@",error);
                                               
                                               [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"Subscribe error"];
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
                                           }];
                    
                } failure:^(NSError *error) {
                    
                    NSLog(@"SDK log : Username/Password Login Error%@",error);
                    
                    [self handleLoginError:@[@0,error]];
                    
                }];
                
            }
}

//Show different login options
- (IBAction)handleOptionClick:(id)sender {
    
    [loginOptionsView setHidden:YES];
    [loginWithLabel setHidden:YES];
    
    if(!self.navigationItem.leftBarButtonItem) {
        
        self.navigationItem.leftBarButtonItem = backButton;
    }
    
    [usernameLoginView setHidden:NO];
    
}


/*
 */


-(void)authUserWith:(NSString *)username andPwd:(NSString *)pwd
{
    if(username.length ==0){
        
        [[inscriptsAppDelegate sharedAppDelegate] showAlertWithTitle:@"" andMessage:@"Please enter username" delegate:self];
        return;
    }
    if(pwd.length ==0){
        
        [[inscriptsAppDelegate sharedAppDelegate] showAlertWithTitle:@"" andMessage:@"Please enter password" delegate:self];
        return;
    }
    
    if(httpAuth)
    {
        [httpAuth cancelRequest];
        httpAuth.delegate = nil;
        httpAuth = nil;
    }
    httpAuth = [[HttpWrapper alloc] init];
    httpAuth.delegate=self;
    
    [[inscriptsAppDelegate sharedAppDelegate]showLoadingView];
    
    NSMutableDictionary *dics = [[NSMutableDictionary alloc]init];
    [dics setValue:@"authenticateUser" forKey:@"action"];
    [dics setValue:username forKey:@"username"];
    [dics setValue:pwd forKey:@"password"];
    [dics setValue:USER_KEYS forKey:@"api-key"];
    NSLog(@"%@", dics);
    [httpAuth requestWithMethod:@"POST" url:API_URL param:dics];
    
}

- (void) HttpWrapper:(HttpWrapper *)wrapper fetchDataSuccess:(NSMutableDictionary *)dicsResponse
{
    if(wrapper == httpAuth){
        
        NSLog(@"RESP %@", dicsResponse);
        if([dicsResponse objectForKey:@"success"]){
            
            NSDictionary *dic =[dicsResponse objectForKey:@"success"];
            //[SHARED_APPDELEGATE showAlertWithTitle:@"" andMessage:[dic objectForKey:@"message"] delegate:self];
            
            [[NSUserDefaults standardUserDefaults] setObject:@[LOGIN_TYPE_USERNAME,usernameTextField.text,passwordTextField.text] forKey:LOGIN_DETAILS];
            
            NSString *loginid =[dic objectForKey:@"userid"];
            [[NSUserDefaults standardUserDefaults] setObject:loginid forKey:LOGIN_USER_ID];
            
        }
        /*
         MainViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainviewcontroller"];
         [self.navigationController pushViewController:viewController animated:YES];
         */
        
        [self onClickSucess:nil];
        
        /*
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
         MainViewController *myNewVC = (MainViewController *)[storyboard instantiateViewControllerWithIdentifier:@"mainviewcontroller"];
         [self.navigationController pushViewController:myNewVC animated:YES];
         */
        
    }
    [[inscriptsAppDelegate sharedAppDelegate] hideLoadingView];
}

-(IBAction)onClickSucess:(id)sender{
    
    /*
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
     MainViewController *myNewVC = (MainViewController *)[storyboard instantiateViewControllerWithIdentifier:@"mainviewcontroller"];
     [self.navigationController pushViewController:myNewVC animated:YES];
     */
    
    MainViewController *uiOption = [self.storyboard instantiateViewControllerWithIdentifier:@"mainviewcontroller"];
    [self.navigationController pushViewController:uiOption animated:YES];
    uiOption = nil;
    [[NSUserDefaults standardUserDefaults] setObject:@[LOGIN_TYPE_USERNAME,usernameTextField.text,passwordTextField.text] forKey:LOGIN_DETAILS];
    //[self handleLogin];
    
    
}

#pragma mark - Reachability Notification Methods

- (void) HttpWrapper:(HttpWrapper *)wrapper fetchDataFail:(NSError *)error
{
    NSLog(@"ERROR %@", error);
    [[inscriptsAppDelegate sharedAppDelegate] hideLoadingView];
}



@end
