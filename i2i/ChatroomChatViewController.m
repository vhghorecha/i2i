//
//  ChatroomChatViewController.m
//  SDKTestApp
//
//  Created by Inscripts on 30/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import "ChatroomChatViewController.h"
#import "ChatRoomChatViewCell.h"
#import <CometChatSDK/CometChatChatroom.h>
#import <CometChatSDK/GroupAVChat.h>
#import "NativeKeys.h"
#import "VideoChatViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "DBManager.h"
#import <StickersFramework/StickersFramework.h>

@interface ChatroomChatViewController () {
    
    ChatRoomChatViewCell *chatViewCell;
    UIBarButtonItem *callButton;
    NSMutableArray *messageArray;
    CometChatChatroom *cometChatChatroom;
    GroupAVChat *groupAVChat;
    UIBarButtonItem *moreButton;
    NSObject<OS_dispatch_queue> *dispatch_queue_chatroom ;
    UIImage *captureImage;
    
    /* Stickers Variables */
    
    BOOL hideStickerFlag;
    UIView *setFrame;
    float height;
    float yCordinate;
    
    StickersControlMethodViewController *sticker;
}

@end

@implementation ChatroomChatViewController

@synthesize currentRoomName;
@synthesize currentRoomID;

@synthesize chatTable;
@synthesize tableViewToBottom;
@synthesize message;
@synthesize wrapper;
@synthesize sendButton;

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
    /* KeyBoard notification required for sticker keyboard */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotifier:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotifier:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomMessageReceivedNotifier:) name:@"com.sdkdemo.chatroomchat.messagereceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomMessageUpdateNotifier:) name:@"com.inscripts.cometchat.updatechatroommessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVConferenceMessage) name:@"com.sdkdemo.avconferencemessagenotifier" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    /* Variable definition */
    messageArray = [[NSMutableArray alloc] init];
    cometChatChatroom = [[CometChatChatroom alloc] init];
    groupAVChat = [[GroupAVChat alloc] init];
    dispatch_queue_chatroom = dispatch_queue_create("queue.chatroom.imagedownload", NULL);
    
    /* Navigation bar settings */
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.title = currentRoomName;
    
    /* Remove default Back button */
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-25"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    callButton = [[UIBarButtonItem alloc] initWithTitle:@"Call" style:UIBarButtonItemStylePlain target:self action:@selector(call)];
    
    moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_custom_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    [moreButton setStyle:UIBarButtonItemStylePlain];
    self.navigationItem.rightBarButtonItems = @[moreButton,callButton];
    
    /* To remove unnecessary rows */
    chatTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    /* To start edge of table row without gap */
    if ([chatTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [chatTable setSeparatorInset:UIEdgeInsetsZero];
    }
    
    /* Wrapper view settings */
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1)];
    borderView.layer.borderColor = [UIColor colorWithRed:212.0f/255.0f green:212.0f/255.0f blue:212.0f/255.0f alpha:1.0f].CGColor;
    borderView.layer.borderWidth = 1.0;
    [wrapper addSubview:borderView];
    [wrapper setBackgroundColor:[UIColor colorWithRed:226.0f/255.0f green:226.0f/255.0f blue:226.0f/255.0f alpha:1.0f]];
    
    /* Send button settings */
    sendButton.enabled = NO;
    [sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
//    [sendButton setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:100.0f/255.0f alpha:0.7f] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:49.0f/255.0f green:140.0f/255.0f blue:231.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];

    [[DBManager getSharedInstance] getChatRoomMessagesForChatRoom:currentRoomID updateFlag:0];
    
    sticker = [[StickersControlMethodViewController alloc] init];
    
    [sticker getSelectedStickers:^(NSDictionary *response) {
        
        [cometChatChatroom sendChatroomStickers:[NSString stringWithFormat:@"%@",[response objectForKey:@"data"]] withsuccess:^(NSDictionary *response) {
            
            
            
        } failure:^(NSError *error) {
            
            
            
        }];
        
    }];
    
    hideStickerFlag = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    /* Store chatroomID in user defaults */
    [[NSUserDefaults standardUserDefaults]setObject:currentRoomID forKey:CURRENT_CHATROOM_ID];
}

- (void)viewDidDisappear:(BOOL)animated
{
    /* Remove chatroomID from user defaults */
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:CURRENT_CHATROOM_ID];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/* Notification will be called prior to Keyboard being seen */
-(void)keyboardNotifier:(NSNotification *)notification
{
    
    CGRect tempKeyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedFrame = [self.view convertRect:tempKeyboardFrame fromView:self.view.window];
    //keyboardFrame = convertedFrame;
    self.tableViewToBottom.constant = convertedFrame.size.height + 50.0f;
    [chatTable updateConstraintsIfNeeded];
    [chatTable layoutIfNeeded];
    
    if ([messageArray count] > 0) {
        [chatTable reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
        [chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messageArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"chatroomchatviewcell";
    chatViewCell = [chatTable dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (chatViewCell == nil) {
        chatViewCell = [[ChatRoomChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else {
        for (UIView *view in chatViewCell.contentView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    /* Define maximum contraints */
    CGSize constraints = CGSizeMake(((self.view.frame.size.width)*2/3 + 8.0f),100000);
    CGFloat wrapperViewX = 0.0f;
    CGFloat wrapperViewWidth = 0.f;
    CGFloat wrapperViewHeight = 0.f;
    
    NSString *messageString = nil;
    
    if ([[[messageArray objectAtIndex:indexPath.row] objectForKey:MESSAGE] isKindOfClass:[NSString class]]) {
        
        messageString = [NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:MESSAGE]];
    }
    NSString *nameString = nil;
    NSString *messageType = [NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:MESSAGE_TYPE_KEY]];
    
    UIView *wrapperView = [UIView new];
    UITextView *textView = [UITextView new];
    UIImageView *imageView = [UIImageView new];
    UILabel *nameLabel = [UILabel new];
    UILabel *timeLabel = [UILabel new];
    
    wrapperView.layer.cornerRadius = 5 ;
    wrapperView.clipsToBounds = YES;
    
    /* If message is sent by you add Me as the name */
    if ([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"fromid"]] isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]]]) {
        
        nameString = @"Me:";
        
    } else {
        /* Else append BuddyName in message */
        nameString = [NSString stringWithFormat:@"%@:",[[[messageArray objectAtIndex:indexPath.row] objectForKey:FROM] capitalizedString]];
    }
    
    [nameLabel setFont:[UIFont systemFontOfSize:14.f]];
    [nameLabel setNumberOfLines:0];
    [nameLabel setLineBreakMode:NSLineBreakByWordWrapping];
    NSDictionary *attributesName = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:14.f], NSFontAttributeName, nil];
    CGRect nameRect = [nameString boundingRectWithSize:constraints options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesName context:nil];
    CGSize sizeName = nameRect.size;
    [nameLabel setText:nameString];
    attributesName = nil;
    
    [nameLabel setFrame:CGRectMake(4.f, 4.f, sizeName.width, sizeName.height)];
    [wrapperView addSubview:nameLabel];
    
    if ([messageType isEqualToString:MESSAGE_TYPE_IMAGE]) {
        
        CGRect imageRect = CGRectMake(4.f, (nameLabel.frame.origin.y + nameLabel.frame.size.height + 4.f), 100.f, 100.f);
        
        if (messageString == nil) {
            
            [imageView setImage:[UIImage imageWithData:[[messageArray objectAtIndex:indexPath.row] objectForKey:MESSAGE]]];
            
        } else {
            if ([[NSFileManager defaultManager] fileExistsAtPath:messageString]) {
                
                [imageView setImage:[UIImage imageWithContentsOfFile:messageString]];
            } else {
                [imageView setImageWithURL:[NSURL URLWithString:messageString] placeholderImage:[UIImage imageNamed:@"default_avatar_thumbnail"] options:0 andResize:imageRect.size withContentMode:UIViewContentModeScaleAspectFill];
            }
        }
        
        [imageView setFrame:imageRect];
        [wrapperView addSubview:imageView];
        
        if ([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"fromid"]] isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]]]) {
            
            if (imageView.frame.size.width > nameLabel.frame.size.width) {
                
                wrapperViewX = self.view.frame.size.width - imageView.frame.size.width - 14.f;
            } else {
                wrapperViewX = self.view.frame.size.width - nameLabel.frame.size.width - 14.f;
            }
            
        } else {
            wrapperViewX = 7.f;
        }
        
        if (imageView.frame.size.width > nameLabel.frame.size.width) {
            
            wrapperViewWidth = 4.f + imageView.frame.size.width + 4.f;
        } else {
            wrapperViewWidth = 4.f + nameLabel.frame.size.width + 4.f;
        }
        
        wrapperViewHeight =  imageView.frame.origin.y + imageView.frame.size.height  + 4.f;
        
    } else if ([messageType isEqualToString:MESSAGE_TYPE_STICKER]) {
        
        CGRect imageRect = CGRectMake(4.f, (nameLabel.frame.origin.y + nameLabel.frame.size.height + 4.f), 100.f, 100.f);
        
        if (messageString == nil) {
            
            [imageView setImage:[UIImage imageWithData:[[messageArray objectAtIndex:indexPath.row] objectForKey:MESSAGE]]];
            
        } else {
            
            [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"StickersFramework.bundle/%@",messageString]]];
            
        }
        
        [imageView setFrame:imageRect];
        [wrapperView addSubview:imageView];
        
        if ([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"fromid"]] isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]]]) {
            
            if (imageView.frame.size.width > nameLabel.frame.size.width) {
                
                wrapperViewX = self.view.frame.size.width - imageView.frame.size.width - 14.f;
            } else {
                wrapperViewX = self.view.frame.size.width - nameLabel.frame.size.width - 14.f;
            }
            
        } else {
            wrapperViewX = 7.f;
        }
        
        if (imageView.frame.size.width > nameLabel.frame.size.width) {
            
            wrapperViewWidth = 4.f + imageView.frame.size.width + 4.f;
        } else {
            wrapperViewWidth = 4.f + nameLabel.frame.size.width + 4.f;
        }
        
        wrapperViewHeight =  imageView.frame.origin.y + imageView.frame.size.height  + 4.f;
        
    } else {
        
        [textView setFont:[UIFont systemFontOfSize:14.0f]];
        [textView setTextContainerInset:UIEdgeInsetsZero];
        [textView setBackgroundColor:[UIColor clearColor]];
        
        /* Disable scroll and editing */
        [textView  setEditable:NO];
        [textView setScrollEnabled:NO];
        
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        [paragraph setLineSpacing:2.0f];
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:14.f], NSFontAttributeName,paragraph ,NSParagraphStyleAttributeName,nil];
        
        [messageString boundingRectWithSize:constraints options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
        
        [textView setText:messageString];
        
        CGSize sizeMessage = [textView sizeThatFits:constraints];
        
        textView.frame = CGRectMake(0.0f,(nameLabel.frame.origin.y + nameLabel.frame.size.height + 4.f), sizeMessage.width, sizeMessage.height);
        
        [wrapperView addSubview:textView];
        
        if ([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"fromid"]] isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]]]) {
            
            if (textView.frame.size.width > nameLabel.frame.size.width) {
                
                wrapperViewX = self.view.frame.size.width - textView.frame.size.width - 14.f;
            } else {
                wrapperViewX = self.view.frame.size.width - nameLabel.frame.size.width - 14.f;
            }
            
        } else {
            wrapperViewX = 7.f;
        }
        
        if (textView.frame.size.width > nameLabel.frame.size.width) {
            
            wrapperViewWidth = 4.f + textView.frame.size.width + 4.f;
            
        } else {
            wrapperViewWidth = 4.f + nameLabel.frame.size.width + 4.f;
        }
        
        
        wrapperViewHeight =  textView.frame.origin.y + textView.frame.size.height  + 4.f;
        
        attributesDictionary = nil;
    }
    
    [wrapperView setFrame:CGRectMake(wrapperViewX, 7.f, wrapperViewWidth, wrapperViewHeight)];
    
    
    /* Define timeString & timeLabel */
    NSTimeInterval _interval = ([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"sent"]] doubleValue]/1000);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *_formatter = [[NSDateFormatter alloc] init];
    [_formatter setLocale:[NSLocale currentLocale]];
    _formatter.dateStyle = NSDateFormatterMediumStyle;
    _formatter.timeStyle = NSDateFormatterShortStyle;
    _formatter.doesRelativeDateFormatting = YES;
    
    NSString *timeString = [_formatter stringFromDate:date];
    
    [timeLabel setFont:[UIFont systemFontOfSize:10.f]];
    [timeLabel setTextColor:[UIColor colorWithRed:103.0f/255.0f green:103.0f/255.0f blue:103.0f/255.0f alpha:1.0]];
    [timeLabel setNumberOfLines:0];
    [timeLabel setLineBreakMode:NSLineBreakByWordWrapping];
    NSDictionary *attributesTime = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:10.f], NSFontAttributeName, nil];
    CGRect timeRect = [timeString boundingRectWithSize:constraints options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesTime context:nil];
    CGSize sizeTime = timeRect.size;
    [timeLabel setText:timeString];
    
    
    if ([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"fromid"]] isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]]]) {
        
        [nameLabel setTextColor:[UIColor whiteColor]];
        [textView setTextColor:[UIColor whiteColor]];
        [wrapperView setBackgroundColor:[UIColor colorWithRed:49.0f/255.0f green:140.0f/255.0f blue:231.0f/255.0f alpha:1.0f]];
        
        [wrapperView setBackgroundColor:[UIColor colorWithRed:49.0f/255.0f green:140.0f/255.0f blue:231.0f/255.0f alpha:1.0f]];
        
        [timeLabel setFrame:CGRectMake(self.view.frame.size.width - sizeTime.width - 7.f, (wrapperView.frame.origin.y + wrapperView.frame.size.height + 2.f ), sizeTime.width, sizeTime.height)];

        
    } else {
        
        
        [wrapperView setBackgroundColor:[UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.f]];
        
        [wrapperView setBackgroundColor:[UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.f]];
        
        [timeLabel setFrame:CGRectMake(7.f, (wrapperView.frame.origin.y + wrapperView.frame.size.height + 2.f ), sizeTime.width, sizeTime.height)];
    }
    
    
    [chatViewCell.contentView addSubview:wrapperView];
    [chatViewCell.contentView addSubview:timeLabel];

                               
    return chatViewCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize constraints = CGSizeMake(((self.view.frame.size.width)*2/3 + 8.0f),100000);
    NSString *messageString = [NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:MESSAGE]];
    NSString *nameString = nil;
    NSString *messageType = [NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:MESSAGE_TYPE_KEY]];
    
    if ([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"fromid"]] isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]]]) {
        
        nameString = @"Me:";
        
    } else {
        /* Else append BuddyName in message */
        nameString = [NSString stringWithFormat:@"%@:",[[[messageArray objectAtIndex:indexPath.row] objectForKey:FROM] capitalizedString]];
    }
    
    NSDictionary *attributesName = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:14.f], NSFontAttributeName, nil];
    CGRect nameRect = [nameString boundingRectWithSize:constraints options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesName context:nil];
    CGSize sizeName = nameRect.size;

    UITextView *textView = [UITextView new];
    [textView setFont:[UIFont systemFontOfSize:14.0f]];
    [textView setTextContainerInset:UIEdgeInsetsZero];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineSpacing:2.0f];
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:14.0f], NSFontAttributeName,paragraph ,NSParagraphStyleAttributeName,nil];
    
    [messageString boundingRectWithSize:constraints options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
    
    [textView setText:messageString];
    
    
    NSTimeInterval _interval = ([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"sent"]] doubleValue]/1000);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *_formatter = [[NSDateFormatter alloc] init];
    [_formatter setLocale:[NSLocale currentLocale]];
    _formatter.dateStyle = NSDateFormatterMediumStyle;
    _formatter.timeStyle = NSDateFormatterShortStyle;
    _formatter.doesRelativeDateFormatting = YES;
    
    NSString *timeString = [_formatter stringFromDate:date];
    NSDictionary *attributesTime = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:10.f], NSFontAttributeName, nil];
    CGRect timeRect = [timeString boundingRectWithSize:constraints options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesTime context:nil];
    CGSize sizeTime = timeRect.size;
    
    timeString = nil;
    messageString = nil;
    attributesDictionary = nil;
    
    if ([messageType isEqualToString:MESSAGE_TYPE_IMAGE] || [messageType isEqualToString:MESSAGE_TYPE_STICKER]) {
        
        return 7.f + 4.f + sizeName.height + 4.f + 100.f + 4.f + (2.f + sizeTime.height) + 2.f;
    } else {
        return 7.f + 4.f + sizeName.height + 4.f + ([textView sizeThatFits:constraints].height + 1.0f) + 4.f + (2.f + sizeTime.height) + 2.f;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [sticker hideStickerKeyboard:YES];
    [setFrame removeFromSuperview];
    hideStickerFlag = NO;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //[message becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.tableViewToBottom.constant = 50.0f;
    [chatTable updateConstraintsIfNeeded];
    [chatTable layoutIfNeeded];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    string = [textField.text stringByReplacingCharactersInRange:range withString:string];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (string.length == 0) {
        
        sendButton.enabled = NO;
    } else {
        
        sendButton.enabled = YES;
    }
    return YES;
}

-(void)handleBackButton
{
    /* Leave current chatroom */
    [cometChatChatroom leaveChatroom:^(NSError *error) {
        NSLog(@"SDK log : ChatRoom leaveChatroom :error %@",error);
        
        [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"leaveChatroom error"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
    }];
    
    /* Pop view controller */
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notification handler
- (void)chatRoomMessageReceivedNotifier:(NSNotification *)notification {
    
//    if (self.isViewLoaded && self.view.window) {
//        
//        NSString *duplicateMsgIdCheck = [NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:ID]];
//        
//        if ([messageArray count]) {
//            for(id msgDic in messageArray){
//                
//                if([[NSString stringWithFormat:@"%@",[msgDic objectForKey:ID]] isEqualToString:duplicateMsgIdCheck]){
//                    
//                    duplicateMsgIdCheck = nil;
//                    return;
//                }
//            }
//        }
//        
//        duplicateMsgIdCheck = nil;
//        
//        if ([[notification userInfo] objectForKey:MESSAGE_TYPE_KEY]) {
//            
//            NSString *messageType = [NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:MESSAGE_TYPE_KEY]];
//            NSMutableDictionary *messageDictionary = [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
//            
//            if ([messageType isEqualToString:MESSAGE_TYPE_VIDEO]) {
//                
//                [messageDictionary setObject:[NSString stringWithFormat:@"Video File : %@",[[notification userInfo] objectForKey:@"message"]]  forKey:@"message"];
//            } else if ([messageType isEqualToString:MESSAGE_TYPE_AUDIO]) {
//                
//                [messageDictionary setObject:[NSString stringWithFormat:@"Audio File : %@",[[notification userInfo] objectForKey:@"message"]]  forKey:@"message"];
//            } else if ([messageType isEqualToString:MESSAGE_TYPE_FILE]) {
//                
//                [messageDictionary setObject:[NSString stringWithFormat:@"File : %@",[[notification userInfo] objectForKey:@"message"]]  forKey:@"message"];
//                
//            } else if (![messageType isEqualToString:MESSAGE_TYPE_STANDARD] && ![messageType isEqualToString:MESSAGE_TYPE_IMAGE] && ![messageType isEqualToString:MESSAGE_TYPE_AUDIO] && ![messageType isEqualToString:MESSAGE_TYPE_FILE]) {
//                
//                messageType = nil;
//                messageDictionary = nil;
//                return;
//            }
//            
////            [messageArray addObject:messageDictionary];
////            [chatTable reloadData];
////            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
////            [chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//
//            [[DBManager getSharedInstance] insertChatRoomMessages:[NSMutableArray arrayWithObjects:messageDictionary, nil] forChatRoom:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CHATROOM_ID]];
//            
//            [[DBManager getSharedInstance] getChatRoomMessagesForChatRoom:currentRoomID updateFlag:0];
//            
//            messageType = nil;
//            messageDictionary = nil;
//            
//        }
//        
//    }
    
    [[DBManager getSharedInstance] getChatRoomMessagesForChatRoom:currentRoomID updateFlag:0];
    
}

- (void)chatRoomMessageUpdateNotifier: (NSNotification *)notification {
    
    messageArray = nil;
    
    if ([[[notification userInfo] objectForKey:@"TAG"] isEqualToString:@"0"]) {
        messageArray = [[notification userInfo] objectForKey:@"data"];
        
        if ([messageArray count] > 0) {
            [chatTable reloadData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
            [chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        
    }
    
}

- (void)handleAVConferenceMessage {
    
    [self.callReceivingWrapper setHidden:NO];
}

#pragma mark - IBAction
- (IBAction)sendMessage:(id)sender {
    
    
    message.text = [message.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [cometChatChatroom sendChatroomMessage:message.text withsuccess:^(NSDictionary *response) {
        
        [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"sendMessage success"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
        
        NSString *duplicateMsgIdCheck = [NSString stringWithFormat:@"%@",[response objectForKey:ID]];
        
        for(id msgDic in messageArray){
            
            if([[NSString stringWithFormat:@"%@",[msgDic objectForKey:ID]] isEqualToString:duplicateMsgIdCheck]){
                
                duplicateMsgIdCheck = nil;
                return;
            }
        }
        
        duplicateMsgIdCheck = nil;
        
        
        /* Get message id and message from response and form message dictionary as follows */
        NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Me",FROM,[response objectForKey:ID],ID,[response objectForKey:SENT_MESSAGE],MESSAGE,@"1",OLD,@0,TYPE,[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],@"fromid",nil];
        long long currentTime = (long long)([[NSDate date] timeIntervalSince1970]*1000);
        [tempDictionary setObject:[NSString stringWithFormat:@"%lld",currentTime] forKey:SENT];
        
        /* Add this messageDic into messageArray and reload table */
//        [messageArray addObject:tempDictionary];
//        [chatTable reloadData];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
//        [chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
        [[DBManager getSharedInstance] insertChatRoomMessages:[NSMutableArray arrayWithObjects:tempDictionary, nil] forChatRoom:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CHATROOM_ID]];
        
        [[DBManager getSharedInstance] getChatRoomMessagesForChatRoom:currentRoomID updateFlag:0];
        
        
    } failure:^(NSError *error) {
        
        NSLog(@"SDK log : ChatRoom messageSent :error %@",error);
        
        [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"sendMessage error"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
    }];
    
    message.text = @"";
    sendButton.enabled = NO;
    
}

- (IBAction)sendAVConference:(id)sender {
    
    [groupAVChat sendConferenceRequest:^(NSDictionary *dictionary) {
        
    } failure:^(NSError *error) {
        
    }];
}


/* Sample method to send image to chatroom 
   Here image is sent using
 - (void)sendImageWithData:(NSData *)imageData
                   success:(void(^)(NSDictionary *response))response
                   failure:(void(^)(NSError *error))failure; */
- (void)sendImageToChatroom {
    
    dispatch_async(dispatch_queue_chatroom, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://s3.amazonaws.com/uifaces/faces/twitter/_everaldo/48.jpg"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cometChatChatroom sendImageWithData:imageData success:^(NSDictionary *response) {
                NSLog(@"SDK log: Chatroom image sending successfull with response = %@",response);
            } failure:^(NSError *error) {
                 NSLog(@"SDK log: Chatroom image sending failed = %@",error);
            }];
        });
    });
}

/* Sample method to send video to chatroom
 Here video is sent using
 - (void)sendVideoWithPath:(NSData *)imageData
 success:(void(^)(NSDictionary *response))response
 failure:(void(^)(NSError *error))failure; */
- (void)sendVideoToChatroom {
    
    NSString *path = @"yourvideofilepath";
    [cometChatChatroom sendVideoWithPath:path success:^(NSDictionary *response) {
         NSLog(@"SDK log: Chatroom video sending successfull with response = %@",response);
    } failure:^(NSError *error) {
        NSLog(@"SDK log: Chatroom image sending failed = %@",error);

    }];
}


#pragma - mark Group AVChat IBAction methods
- (IBAction)acceptAction:(id)sender {
    
    [groupAVChat joinConference:^(NSDictionary *response) {
        
         NSLog(@"SDK log: JOIN CONFERENCE RESPONSE %@",response);
        
        VideoChatViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"videochatviewcontroller"];
        [self.navigationController pushViewController:viewController animated:NO];
        viewController = nil;
        
    } failure:^(NSError *error) {
        
        NSLog(@"SDK log: JOIN CONFERENCE ERROR %@",error);
    }];
    
    [self.callReceivingWrapper setHidden:YES];
}

- (IBAction)rejectAction:(id)sender {
    
    [self.callReceivingWrapper setHidden:YES];
}

/* Required for sticker keyboard */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (hideStickerFlag) {
        [sticker hideStickerKeyboard:YES];
        
        [self stickerKeyboardAction:nil];
    }
    
}

- (IBAction)stickerKeyboardAction:(id)sender {
    
    if (!hideStickerFlag) {
        
        [message becomeFirstResponder];
        [message resignFirstResponder];
        
        setFrame = [[UIView alloc] init];
        
        
        setFrame = [sticker stickerKeyboardSetFrame:0 viewWidth:self.view.frame.size.width viewHeight:self.view.frame.size.height];
        
        [setFrame layoutIfNeeded];
        
        [self.view addSubview:setFrame];
        
        hideStickerFlag = YES;
        
    } else {
        
        [sticker hideStickerKeyboard:YES];
        
        [setFrame removeFromSuperview];
        
        hideStickerFlag = NO;
        
        [message becomeFirstResponder];
        [message resignFirstResponder];
        
        self.tableViewToBottom.constant = 50.0f;
        [chatTable updateConstraintsIfNeeded];
        [chatTable layoutIfNeeded];
    }
    
}

#pragma mark - Private Methods

- (void)call {
   
    [groupAVChat sendConferenceRequest:^(NSDictionary *response) {
        
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"videochatviewcontroller"] animated:NO];
        
        NSLog(@"SDK log: SEND CONFERENCE REQUEST SUCCESS %@",response);
        
    } failure:^(NSError *error) {
        
        NSLog(@"SDK log: SEND CONFERENCE REQUEST ERROR %@",error);
    }];
}

-(void)OrientationDidChange:(NSNotification*)notification
{
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
    
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
        NSLog(@"landscape");
        dispatch_async(dispatch_get_main_queue(), ^{
        [chatTable reloadData];
        });
    }
    else if(Orientation==UIDeviceOrientationPortrait)
    {
        NSLog(@"portrait");
        dispatch_async(dispatch_get_main_queue(), ^{
            [chatTable reloadData];
        });
    }
}

- (void)showOptions {
    moreButton.enabled = NO;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (NSString *option in @[@"Capture Image",@"Capture Video",@"Share Photo",@"Share Video",@"Share Audio",@"Share File"]) {
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
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.delegate = self;
    
    switch (buttonIndex) {
        case 0: {
            
            cameraUI.allowsEditing = YES;
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
                //todo if device has no camera
                
                cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable To Locate Camera" message:@"No Camera found." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [alert show];
            } else {
                cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                cameraUI.mediaTypes =
                [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
                
            }
            
            [self presentViewController:cameraUI animated:YES completion:nil];
            
            break;
        }
        case 1: {
            
            cameraUI.allowsEditing = NO;
            cameraUI.mediaTypes = [NSArray arrayWithObject:@"public.movie"];
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
                NSLog(@"Photo Gallery");
                
                cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable To Locate Camera" message:@"No Camera found." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [alert show];
                
            }else{
                cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                cameraUI.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
                cameraUI.wantsFullScreenLayout = YES;
                cameraUI.showsCameraControls = YES;
            }
            
            cameraUI.videoQuality = UIImagePickerControllerQualityTypeLow;
            
            [self presentViewController:cameraUI animated:NO completion:nil];
            
            break;
        }
        case 2: {
            
            cameraUI.allowsEditing = YES;
            cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
            
            [self presentViewController:cameraUI animated:YES completion:nil];
            
            break;
        }
        case 3: {
            
            cameraUI.allowsEditing = NO;
            cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
            cameraUI.videoQuality = UIImagePickerControllerQualityTypeLow;
            cameraUI.wantsFullScreenLayout = YES;
            
            [self presentViewController:cameraUI animated:YES completion:nil];
            
            break;
        }
        case 4: {
            
            /* Here, you can also give the path of image file from Document's Directory. */
            [cometChatChatroom sendAudioWithPath:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp3"] success:^(NSDictionary *response) {
                NSLog(@"SDK Log : Send Audio from URL Response = %@",response);
                
                [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"sendAudio success"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
                
                
            } failure:^(NSError *error) {
                NSLog(@"SDK Log : Send Audio from URL Error = %@",error);
            }];
        }
        break;
        case 5: {
            
            /* Here, you can also give the path of image file from Document's Directory. */
            [cometChatChatroom sendFileWithPath:[[NSBundle mainBundle] pathForResource:@"samplefile" ofType:@"txt"] success:^(NSDictionary *response) {
                NSLog(@"SDK Log : Send File from URL Response = %@",response);
                
                [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"sendFile success"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
                
            } failure:^(NSError *error) {
                NSLog(@"SDK Log : Send File from URL Error = %@",error);
            }];
        }
        break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                                   if([info valueForKey:UIImagePickerControllerEditedImage] && [info valueForKey:UIImagePickerControllerEditedImage] != [NSNull null]){
                                       captureImage = [info valueForKey:UIImagePickerControllerEditedImage];
                                       
                                       NSData *data = UIImageJPEGRepresentation(captureImage, 0.6);
                                       
                                       [cometChatChatroom sendImageWithData:data success:^(NSDictionary *response) {
                                           NSLog(@"SDK Log : Send ImageData Response = %@",response);
                                           
                                           [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"sendVideo success"];
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
                                           
                                           NSString *duplicateMsgIdCheck = [response objectForKey:ID];
                                           
                                           
                                           for(id msgDic in messageArray){
                                               
                                              if([[NSString stringWithFormat:@"%@",[msgDic objectForKey:ID]] isEqualToString:[NSString stringWithFormat:@"%@",duplicateMsgIdCheck]]){
                                                   
                                                   duplicateMsgIdCheck = nil;
                                                   return;
                                               }
                                           }
                                           
                                           duplicateMsgIdCheck = nil;
                                           
                                           /* Get message id and message from response and form message dictionary as follows */
                                           NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Me",FROM,[response objectForKey:ID],ID,[response objectForKey:MESSAGE],MESSAGE,@"1",OLD,@0,TYPE,[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],@"fromid",MESSAGE_TYPE_IMAGE,MESSAGE_TYPE_KEY,nil];
                                           
                                           long long currentTime = (long long)([[NSDate date] timeIntervalSince1970]*1000);
                                           [tempDictionary setObject:[NSString stringWithFormat:@"%lld",currentTime] forKey:SENT];
                                           
                                           /* Add this messageDic into messageArray and reload table */
//                                           [messageArray addObject:tempDictionary];
//                                           [chatTable reloadData];
//                                           NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
//                                           [chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];

                                           [[DBManager getSharedInstance] insertChatRoomMessages:[NSMutableArray arrayWithObjects:tempDictionary, nil] forChatRoom:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CHATROOM_ID]];
                                           
                                           [[DBManager getSharedInstance] getChatRoomMessagesForChatRoom:currentRoomID updateFlag:0];
                                           
                                       } failure:^(NSError *error) {
                                           NSLog(@"SDK Log : Send ImageData Error = %@",error);
                                       }];
                                       
                                   }else{
                                       
                                       NSURL *videoURL = [info valueForKey:UIImagePickerControllerMediaURL];
                                       NSString *pathToVideo = [videoURL path];
                                       BOOL okToSaveVideo = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToVideo);
                                       if (okToSaveVideo) {
                                           //UISaveVideoAtPathToSavedPhotosAlbum(pathToVideo, self, @selector(reseting), NULL);
                                           [cometChatChatroom sendVideoWithURL:videoURL success:^(NSDictionary *response) {
                                               NSLog(@"SDK Log : Send ImageData Response = %@",response);
                                               
                                               [NativeKeys getLogOType:LOG_TYPE_CHATROOM ForMessage:@"sendVideo success"];
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"com.sdkdemo.logsview.refreshLogs" object:nil];
                                               
                                               /* Get message id and message from response and form message dictionary as follows */
                                               
                                           } failure:^(NSError *error) {
                                               NSLog(@"SDK Log : Send ImageData Error = %@",error);
                                           }];
                                           
                                       } else {
                                           NSLog(@"Some Error While video save on video path");
                                       }
                                       
                                   }
                                   
                                   
                                   /* Select Image from Camera or PhotoLibrary and Reduce Quality */
                                   
                                   
                                   
                               }];
}

@end
