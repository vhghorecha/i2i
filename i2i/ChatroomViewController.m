//
//  ChatroomViewController.m
//  SDKTestApp
//
//  Created by Inscripts on 29/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import "ChatroomViewController.h"
#import "ChatroomListViewCell.h"
#import <CometChatSDK/CometChatChatroom.h>
#import "NativeKeys.h"
#import "ChatroomChatViewController.h"
#import "DBManager.h"

@interface ChatroomViewController () {

    ChatroomListViewCell *chatListCell;
    
    CometChatChatroom *cometChatRoom;
    NSMutableArray *chatRoomList;
}

@end

@implementation ChatroomViewController
@synthesize chatRoomListTable;
@synthesize getChatroomList;

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
    cometChatRoom = [[CometChatChatroom alloc] init];
    chatRoomList = [[NSMutableArray alloc] init];
    
    /* Navigation bar settings */
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.title = @"Chatroom List";
    
    /* Remove default Back button */
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-25"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    /* To start edge of table row without gap */
    if ([chatRoomListTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [chatRoomListTable setSeparatorInset:UIEdgeInsetsZero];
    }
    
    
    /* To remove unnecessary rows */
    chatRoomListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    /* Open chatroom list button settings */
    [getChatroomList setBackgroundColor:[UIColor colorWithRed:226.0f/255.0f green:226.0f/255.0f blue:226.0f/255.0f alpha:1.0f]];
    [getChatroomList setTitleColor:[UIColor colorWithRed:49.0f/255.0f green:140.0f/255.0f blue:231.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];

    /* Subscribe to Chatroom set mode argument to YES if you want to strip html elements */
   
    [cometChatRoom subscribeToChatroomWithMode:YES
     
                     onChatroomMessageReceived:^(NSDictionary *response) {
        /* Chatroom messages will be recieved in this callback */
        NSLog(@"SDK log : chatroom onChatroomMessageReceived %@",response);
        
        [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"onChatroomMessageReceived"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
        
        /* Notify if user has joined any chatrom */
        if ([[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CHATROOM_ID]) {
            
            [[DBManager getSharedInstance] insertChatRoomMessages:[NSMutableArray arrayWithObjects:response, nil] forChatRoom:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CHATROOM_ID]];
           
            NSMutableDictionary *tempdic = [NSMutableDictionary dictionaryWithDictionary:response];
                           
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.chatroomchat.messagereceived" object:nil userInfo:tempdic];
            
            
        }
                         
                     } onActionMessageReceived:^(NSDictionary *response) {
         /* Callback block for actions in chatroom */
        
         NSLog(@"SDK log : on Action Message received %@",response);
        
        if ([[response objectForKey:@"action_type"] isEqualToString:@"10"]) {
            NSLog(@"SDK log : chatroom onKicked %@",response);
            
            [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"onKicked"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
            
        } else if ([[response objectForKey:@"action_type"] isEqualToString:@"11"]) {
            NSLog(@"SDK log : chatroom onBanned %@",response);
            
            [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"onBanned"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];

        }
    }
    onChatroomsListReceived:^(NSDictionary *response) {
        
        /* Chatrooms list will be received here */
         NSLog(@"SDK log : chatroom chatroomsListReceived %@",response);
        
        [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"chatroomsListReceived"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
        
        /* Update Chatrooms table */
        [chatRoomList removeAllObjects];
        NSArray *chatrooms = response.allKeys;
        
        for (int i = 0 ; i < [chatrooms count]; i++) {
            
            if ([response objectForKey:[chatrooms objectAtIndex:i]]) {
                [chatRoomList addObject:[response objectForKey:[chatrooms objectAtIndex:i]]];
            }
        }
       
        [chatRoomListTable reloadData];
        
    } onChatroomMembersListReceived:^(NSDictionary *response) {
        
        /* Chatrooms list will be received here */
        NSLog(@"SDK log : chatroom ChatroomMembersListReceived %@",response);
        
        [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"ChatroomMembersListReceived"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
        
    } onAVChatMessageReceived:^(NSDictionary *response) {
        NSLog(@"SDK log : AudioVideo Group Conference message received = %@",response);
        
        
        /* Please Note that each time you join a chatroom last ten messages are received in onChatroomMessageReceived: OR onAVChatMessageReceived: callback blocks. Thus, AudioVideo Conference call messages have to be handled accordingly. */
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.avconferencemessagenotifier" object:nil];
        
    } failure:^(NSError *error) {
        NSLog(@"SDK log : chatroom subscribe error %@",error);
        
        [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"Subscribe error"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [chatRoomList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"chatroomlistcell" ;
    NSDictionary *buddyData = [chatRoomList objectAtIndex:indexPath.row];
    //NSLog(@"buddy data in cell = %@",buddyData);
    chatListCell = [chatRoomListTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (chatListCell == nil) {
        chatListCell = [[ChatroomListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    /* Show chatroom name in cell */
    chatListCell.chatRoomName.text = [[buddyData objectForKey:CHATROOM_NAME] capitalizedString];
    
    if ([[NSString stringWithFormat:@"%@",[buddyData objectForKey:@"type"]] isEqualToString:@"1"]) {
        
        [chatListCell.protectedIcon setHidden:NO];
        
    } else {
        [chatListCell.protectedIcon setHidden:YES];
    }
    chatListCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return chatListCell;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    
    switch (section) {
            
        case 0: return @"  No Chatroom available.";
            break;
            
        default:
            break;
    }
    return @"";
}


-(void)handleBackButton
{
    /* Pop view controller */
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /* Join selected chatroom */
    /* For joining a password protected room which is not created by you (i.e having parameters s = 0 and type = 1),you must take password from user, perform SHA1 encoding and then send to server. For any other case just set password as empty string */
    
    NSString *password = [[chatRoomList objectAtIndex:indexPath.row] objectForKey:CHATROOM_PASSWORD];
    
    if ([[NSString stringWithFormat:@"%@",[[chatRoomList objectAtIndex:indexPath.row] objectForKey:TYPE]] isEqualToString:@"1"] && [[[chatRoomList objectAtIndex:indexPath.row] objectForKey:S] isEqual:@0]) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        //For password-protected chatroom you have to input the password from the logged-in user and form the password as given below:
        //Eg.If the user has entered @"123".
        password = [CometChatChatroom getSHA1ValueOfString:@"123"];
        
        NSLog(@"SDK Log : Modify code for Password-Protected chatroom");
        
        //Remove return statement to continue the execution of joinChatroom(for password protected chatroom) with correct password.
        return;
    }
    
    [tableView setUserInteractionEnabled:NO];
    
    /* Provide chatroomName, ID and password for joining room */
    [cometChatRoom joinChatroom:[[chatRoomList objectAtIndex:indexPath.row] objectForKey:CHATROOM_NAME] chatroomID:[[chatRoomList objectAtIndex:indexPath.row] objectForKey:ID] chatroomPassword:password success:^(NSDictionary *response) {
        
        
        [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"onJoinChatroom"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
        
        /* Join chatroom response successful */
        ChatroomChatViewController *chatView = [self.storyboard instantiateViewControllerWithIdentifier:@"chatroomchatviewcontroller"];
        chatView.currentRoomID = [[chatRoomList objectAtIndex:indexPath.row] objectForKey:ID];
        chatView.currentRoomName = [[chatRoomList objectAtIndex:indexPath.row] objectForKey:CHATROOM_NAME];
        
        [self.navigationController pushViewController:chatView animated:YES];
         chatView = nil;
        
        [tableView setUserInteractionEnabled:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
    } failure:^(NSError *error) {
        
        /* Error occured while joining chatroom */
        [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"onJoinChatroom error"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
        
        NSLog(@"SDK log : chatroom join error %@",error);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Joining Failed" message:@"Error while joinig" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        [tableView setUserInteractionEnabled:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if ([chatRoomList count] == 0) {
                return 44.0f;
            }
            break;
            
        default:
            break;
    }
    return 0.0f;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getChatroomList:(id)sender {
    
    NSLog(@"CLICK");
    
    /* Get all chatroom list */
    [cometChatRoom getAllChatrooms:^(NSDictionary *response) {
        NSLog(@"SDK log : chatroom getAllChatrooms %@",response);
        
        [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"getAllChatrooms"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
        
        /* Chatroom list will be received in this block */
        [chatRoomList removeAllObjects];
        NSArray *chatrooms = response.allKeys;
        
        for (int i = 0 ; i < [chatrooms count]; i++) {
            
            if ([response objectForKey:[chatrooms objectAtIndex:i]]) {
                [chatRoomList addObject:[response objectForKey:[chatrooms objectAtIndex:i]]];
            }
        }
        
        [chatRoomListTable reloadData];
    } failure:^(NSError *error) {
        /* Error occured while fetching chatroomlist */
        NSLog(@"SDK log : chatroom error getAllChatrooms %@",error);
    }];
}
@end
