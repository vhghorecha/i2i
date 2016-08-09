//
//  MainViewController.m
//  SDKTestApp
//
//  Created by Inscripts on 03/10/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import "MainViewController.h"
#import <CometChatSDK/CometChat.h>
#import "NativeKeys.h"
#import "OneOnOneViewController.h"
#import "ChatroomViewController.h"
#import "LogsViewController.h"
#import "PushNotification.h"
#import "DBManager.h"
#import "inscriptsAppDelegate.h"

@interface MainViewController () {
    
    CometChat *cometChat;
    NSString *siteURL;
    UIBarButtonItem *moreButton;
    
    NSDictionary *buddyChannelList;
    
}

@end

@implementation MainViewController

@synthesize oneOnOneButton;
@synthesize chatroomButton;
@synthesize logButton;
@synthesize logoutButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* Variable Initialization */
    cometChat = [[CometChat alloc] initWithAPIKey:USER_KEYS];
    
    /* Navigation bar settings */
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.title = @"i2iApp";
    
    moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_custom_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    [moreButton setStyle:UIBarButtonItemStylePlain];
    self.navigationItem.rightBarButtonItems = @[moreButton];
    
    //Settings for buttons
    for (UIButton *button in @[oneOnOneButton,chatroomButton,logButton,logoutButton]) {
        
        button.layer.cornerRadius = 5; // this value vary as per your desire
        button.clipsToBounds = YES;
    }
   
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:BUDDY_LIST];
    
    /* Remove previous log from user defaults */
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:LOG_LIST];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGGED_IN_USER];
    
    
    /* Subscribe to One On One Chat ONLY AFTER successful login.  Set mode argument to YES if you want to strip html elements */
    [cometChat subscribeWithMode:YES onMyInfoReceived:^(NSDictionary *response) {
        
        
         NSLog(@"SDK log : OneOnOne MYInfo %@",response);
        
        if ([response objectForKey:ID]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",[response objectForKey:ID]] forKey:LOGGED_IN_USER];
            
            [PushNotification subscribeToParseChannel:[response objectForKey:@"push_channel"]];

        }
 
    } onGetOnlineUsers:^(NSDictionary *response) {
        
        /* Online users list will be received here */
        NSLog(@"SDK log : OneOnOne onGetOnlineUsers %@",response);
        
        buddyChannelList = [NSMutableDictionary new];
        buddyChannelList = [NSDictionary dictionaryWithDictionary:response];
        
        [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"onGetOnlineUsers"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.logsview.refreshLogs" object:nil];
        
        NSLog(@"reponse.allKeys : %@  ",response.allKeys);
        
        /* Update buddylist table */
        NSMutableArray *buddyList = [[NSMutableArray alloc] init];
        NSArray *users = response.allKeys;
        
        for (int i = 0 ; i < [users count]; i++) {
            
            if ([response objectForKey:[users objectAtIndex:i]]) {
                [buddyList addObject:[response objectForKey:[users objectAtIndex:i]]];
            }
        }
        
                NSLog(@"BuddyList Check : %@",buddyList);
        
        /* Store buddyList in userdefaults */
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:buddyList] forKey:BUDDY_LIST];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        /* Send notification to OneOnOneView to refresh buddyList */
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.oneononeview.refreshBuddyList" object:nil];
        
    } onMessageReceived:^(NSDictionary *response) {
        
        /* One On One messages will be recieved in this callback */
        NSLog(@"SDK log : OneOnOne onMessageReceived %@",response);
        
        
            
            NSString *buddyID = [response objectForKey:@"from"];
            NSString *buddyChannel = [[buddyChannelList objectForKey:[NSString stringWithFormat:@"_%@",buddyID]] objectForKey:@"ch"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [cometChat sendDeliverdReceipt:[response objectForKey:@"id"] channel:buddyChannel failure:^(NSError *error) {
                    
                    NSLog(@"sendDeliverdReceipt Error : %@",error);
                    
                }];
                
            });
            
        
        
       
        
        [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"onMessageReceived"];
        
        [[DBManager getSharedInstance] insertBuddyMessages:@{@"messages":response}];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_BUDDY_ID]) {
            
            /* If message is received from current buddy (Buddy you are chatting with), then send notification to OneOnOneChatView controller */
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_BUDDY_ID] isEqualToString:[NSString stringWithFormat:@"%@",[response objectForKey:FROM]]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.oneononechat.messagereceived" object:nil userInfo:response];
            }
        }
        
    } onAnnouncementReceived:^(NSDictionary *response) {
        
        NSLog(@"SDK log : OneOnOne announcement %@",response);
        
        /* Announcements messages will be recieved in this callback */
        [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"onAnnouncementReceived"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.logsview.refreshLogs" object:nil];
        
    } onAVChatMessageReceived:^(NSDictionary *response) {
        NSLog(@"SDK log : AVChat message received = %@",response);
        
        [NativeKeys getLogOType:LOG_TYPE_AVCHAT ForMessage:@"onAVChatMessageReceived"];
        
        if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_BUDDY_ID]] isEqualToString:[NSString stringWithFormat:@"%@",[response objectForKey:FROM]]] || ([[response objectForKey:MESSAGE_TYPE_KEY] integerValue] == 33)) {
            
           [[NSNotificationCenter defaultCenter] postNotificationName:@"com.demosdkproject.handleavchatcalls" object:nil userInfo:response];
        }
        
    } onActionMessageReceived:^(NSDictionary *response) {
        NSLog(@"SDK Log : onActionMessageReceived = %@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.demosdkproject.handleactionmessagecalls" object:nil userInfo:response];
    } failure:^(NSError *error) {
        /* Subscribe failure will be handled here */
        NSLog(@"SDK log : OneOnOne subscribe error %@",error);
        [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"Subscribe failure"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.logsview.refreshLogs" object:nil];
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)openOneOnOneList:(id)sender {
    [cometChat getOnlineUsersWithResponse:^(NSDictionary *response) {
        NSLog(@"SDK Log online users : %@",response);
        
        /* Update buddylist table */
        NSMutableArray *buddyList = [[NSMutableArray alloc] init];
        NSArray *users = response.allKeys;
        
        for (int i = 0 ; i < [users count]; i++) {
            
            if ([response objectForKey:[users objectAtIndex:i]]) {
                [buddyList addObject:[response objectForKey:[users objectAtIndex:i]]];
            }
        }
        
        
        /* Store buddyList in userdefaults */
        //[[NSUserDefaults standardUserDefaults] setObject:buddyList forKey:BUDDY_LIST];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:buddyList] forKey:BUDDY_LIST];
        
        /* Send notification to OneOnOneView to refresh buddyList */
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.oneononeview.refreshBuddyList" object:nil];

        
    } failure:^(NSError *error) {
        NSLog(@"SDK Log online users error: %@",error);
    }];
    OneOnOneViewController *buddyListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"oneononeviewcontroller"];
    [self.navigationController pushViewController:buddyListViewController animated:YES];
    buddyListViewController = nil;
}

- (IBAction)openChatroomList:(id)sender {
    
    ChatroomViewController *chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"chatroomviewcontroller"];
    [self.navigationController pushViewController:chatViewController animated:YES];
    chatViewController = nil;
}

- (IBAction)showLogs:(id)sender {
    
    LogsViewController *logsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"logsviewcontroller"];
    [self.navigationController pushViewController:logsViewController animated:YES];
    logsViewController = nil;
}

- (IBAction)logout:(id)sender {
    
    [cometChat logoutWithSuccess:^(NSDictionary *response) {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_DETAILS];
        [self.navigationController popViewControllerAnimated:YES];
        [PushNotification unsubscribeAllParseChannels];
        [[DBManager getSharedInstance] truncateDatabseTables];
    } failure:^(NSError *error) {
        
    }];
}

- (void)showOptions {
    moreButton.enabled = NO;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (NSString *option in @[@"Change Status",@"Change Status message",@"Set translation language"]) {
        [actionSheet addButtonWithTitle:option];
    }
    // Also add a cancel button
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showFromBarButtonItem:moreButton animated:YES];
    
    actionSheet = nil;
}

#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    moreButton.enabled = YES;
    
    if (buttonIndex == actionSheet.cancelButtonIndex){
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            
            [cometChat changeStatus:STATUS_BUSY success:^(NSDictionary *response) {
                
                NSLog(@"SDK Log : Change status Response = %@",response);
                
            } failure:^(NSError *error) {
                
                NSLog(@"SDK Log : Change status Error = %@",error);
            }];
            
            break;
        case 1:
            
            [cometChat changeStatusMessage:@"I'm available" success:^(NSDictionary *response) {
                
                NSLog(@"SDK Log : Change status message Response = %@",response);
                
            } failure:^(NSError *error) {
                
                NSLog(@"SDK Log : Change status message Error = %@",error);
            }];
            
            break;
        
        case 2:
            
            [cometChat setTranslationLanguage:French success:^(NSDictionary *response) {
                
                NSLog(@"SDK Log : Set Translation language Response = %@",response);
                
            } failure:^(NSError *error) {
                
                NSLog(@"SDK Log : Set Translation language Error = %@",error);
            }];
            break;
            
    }
}


@end
