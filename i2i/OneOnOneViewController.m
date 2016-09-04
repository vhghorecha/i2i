//
//  OneOnOneViewController.m
//  SDKTestApp
//
//  Created by Inscripts on 29/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import "OneOnOneViewController.h"
#import "OneOnOneListViewCell.h"
#import "NativeKeys.h"
#import "OneOnOneChatViewController.h"
#import "ChatroomViewController.h"
#import <CometChatSDK/CometChat.h>
#import "inscriptsAppDelegate.h"

@interface OneOnOneViewController () {

    OneOnOneListViewCell *chatListCell;
    UIBarButtonItem *moreButton;
    CometChat *cometChat;
    
    /* Buddylist array to store list of users */
    NSMutableArray *buddyList;
    NSMutableArray *unbanList;
    
}
@end

@implementation OneOnOneViewController
@synthesize buddyListTable,unblockUserLabel,unblockUserLabelHeight;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* Define notifications */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBuddyList) name:@"com.inscripts.oneononeview.refreshBuddyList" object:nil];
    
    /* Variable Initialization */
    unbanList = [[NSMutableArray alloc] init];
    buddyList = [[NSMutableArray alloc] init];
    cometChat = [[CometChat alloc] initWithAPIKey:USER_KEYS];
    
    /* Updated buddylist with buddyList in userdefaults */
    if ([[NSUserDefaults standardUserDefaults] objectForKey:BUDDY_LIST]) {
        //[buddyList addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:BUDDY_LIST]];
        //[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:buddyList] forKey:BUDDY_LIST];
        [buddyList addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:BUDDY_LIST]]];
    }
    
    /* Navigation bar settings */
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.navigationItem.title = @"User List";
    
    /* Remove default Back button */
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-25"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_custom_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    [moreButton setStyle:UIBarButtonItemStylePlain];
    self.navigationItem.rightBarButtonItem = moreButton;
    
    /* To start edge of table row without gap */
    if ([buddyListTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [buddyListTable setSeparatorInset:UIEdgeInsetsZero];
    }

    /* To remove unnecessary rows */
    buddyListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    cometChat = [[CometChat alloc] initWithAPIKey:USER_KEYS];
    [cometChat createUser:@"testuser4" password:@"user123" link:@"" avatar:@"" displayName:@"" success:^(NSDictionary *response) {
        NSLog(@"response : %@",response);
    } failure:^(NSError *error) {
        NSLog(@"error : %@",error);
    }];
    
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
    return [buddyList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"oneononechatlistcell" ;
    NSDictionary *buddyData = [buddyList objectAtIndex:indexPath.row];
    //NSLog(@"buddy data in cell = %@",buddyData);
    chatListCell = [buddyListTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (chatListCell == nil) {
        chatListCell = [[OneOnOneListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if([self.navigationItem.title isEqual:@"Unblock User"]){
        [chatListCell statusIcon].hidden = YES;
    }else{
        [chatListCell statusIcon].hidden = NO;
    }
    
   
    /* Show buddy name in cell */
    chatListCell.buddyName.text = [[buddyData objectForKey:BUDDY_NAME] capitalizedString];
    chatListCell.statusMessage.text = [buddyData objectForKey:M];
    chatListCell.buddyAvatar.image = [UIImage imageNamed:@"default_avatar_thumbnail.png"];
    
    if([[buddyData objectForKey:S] isEqualToString:ONLINE_STATUS_AVAILABLE]) {
        chatListCell.statusIcon.image = [UIImage imageNamed:@"ic_user_available"];
    }
    else if ([[buddyData objectForKey:S] isEqualToString:ONLINE_STATUS_AWAY]){
        chatListCell.statusIcon.image = [UIImage imageNamed:@"ic_user_away"];
    }
    else if ([[buddyData objectForKey:S] isEqualToString:ONLINE_STATUS_BUSY]){
        chatListCell.statusIcon.image = [UIImage imageNamed:@"ic_user_busy"];
    }
    else if ([[buddyData objectForKey:S]isEqualToString:ONLINE_STATUS_OFFLINE] || [[buddyData objectForKey:S]isEqualToString:ONLINE_STATUS_INVISIBLE]){
        chatListCell.statusIcon.image = [UIImage imageNamed:@"ic_user_offline"];
    }
    
    chatListCell.buddyID = [NSString stringWithFormat:@"%@",[buddyData objectForKey:ID]];
    chatListCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    chatListCell.buddyChannel = [NSString stringWithFormat:@"%@",[buddyData objectForKey:@"ch"]];
    return chatListCell;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    
    switch (section) {
            
        case 0:
            if([self.navigationItem.title isEqual:@"User List"]){
                return @"  No users online at the moment.";
            }else{
                return @"  No users to unblock at the moment.";
            }
            
            break;
            
        default:
            break;
    }
    return @"";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OneOnOneListViewCell *selectedCell = (OneOnOneListViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    OneOnOneChatViewController *chatView = [self.storyboard instantiateViewControllerWithIdentifier:@"oneononechatviewcontroller"];
    if([self.navigationItem.title isEqual:@"User List"]){
        
        chatView.buddyID = selectedCell.buddyID;
        chatView.buddyName = selectedCell.buddyName.text;
        chatView.buddyChannel = selectedCell.buddyChannel;
        [self.navigationController pushViewController:chatView animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        selectedCell = nil;
        chatView = nil;
    } else{
        
        [cometChat unblockUser:selectedCell.buddyID success:^(NSDictionary *response) {
            NSLog(@"SDK Log : Unblock User Response : %@",response);
            [self.navigationController popViewControllerAnimated:NO];
        } failure:^(NSError *error) {
            NSLog(@"SDK Log : Error Message Unblock User : %@",error);
        }];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if ([buddyList count] == 0) {
                return 44.0f;
            }
            break;
            
        default:
            break;
    }
    return 0.0f;
}

-(void)handleBackButton
{
    /* Pop view controller */
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)showOptions {
    moreButton.enabled = NO;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (NSString *option in @[@"Unblock User",@"Broadcast Message"]) {
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
        
        
        case 0:{
            NSLog(@"Unblock User");
            
            [cometChat getBlockedUsersWithResponse:^(NSDictionary *response) {
                NSLog(@"SDK Log : Get Blocked Users Response %@",response);
                
                for(id value in [response allKeys]){
                    NSLog(@"Get Block User response check : %@",[response objectForKey:value]);
                    NSString *myURL = @"http://api.randomuser.me/portraits/men/1.jpg";
                    NSString *buddyName = [[response objectForKey:value] objectForKey:@"name"];
                    NSString *buddyId = [[response objectForKey:value] objectForKey:@"id"];
                    
                    [unbanList addObject:@{@"a":myURL,@"d":@"1",@"g":@"",@"id":buddyId,@"l":@"",@"m":@"",@"n":buddyName,@"s":@""}];
                }
                
                unblockUserLabelHeight.constant = 50.0f;
                [self.view updateConstraintsIfNeeded];
                
                [buddyList removeAllObjects];
                [buddyList addObjectsFromArray:unbanList];
                [buddyListTable reloadData];
                
                self.navigationItem.title = @"Unblock User";
            } failure:^(NSError *error) {
                NSLog(@"SDK Log : Error Blocked Users = %@",error);
            }];
        }
            break;
        case 1:{
            NSLog(@"Broadcast");
            [cometChat broadcastMessage:@"Test Message" toUsers:@[@"30",@"72"] success:^(NSDictionary *response) {
                NSLog(@"SDK Log : BroadCast Response : %@",response);
            } failure:^(NSError *error) {
                NSLog(@"SDK Log : BroadCast Error : %@",error);
            }];
        }
            break;
        case 2:{
            NSLog(@"Create User");
            [cometChat createUser:@"testusercheck" password:@"user123" link:@"" avatar:@"" displayName:@"" success:^(NSDictionary *response) {
                NSLog(@"SDK Log Create User Response : %@",response);
            } failure:^(NSError *error) {
                NSLog(@"SDK Log Error : %@",error);
            }];
        }
            break;
        case 3:{
            NSLog(@"Remove User");
            [cometChat removeUserByID:@"8" success:^(NSDictionary *reponse) {
                NSLog(@"SDK Log Remove User Response : %@",reponse);
            } failure:^(NSError *error) {
                NSLog(@"SDK Log Remove User Error : %@",error);
            }];
        }
            break;
    }
}

#pragma mark - Notification handler
/* Notification handler for one on one chat*/
- (void) refreshBuddyList
{
    self.navigationItem.title = @"User List";
    /* Remove all users form list */
     [buddyList removeAllObjects];
    
    /* Refresh buddyList with updated buddylist in userdefaults */
    //[buddyList addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:BUDDY_LIST]];
    [buddyList addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:BUDDY_LIST]]];
    
    [buddyListTable reloadData];
}

@end
