//
//  OneOnOneChatViewController.m
//  SDKTestApp
//
//  Created by Inscripts on 30/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import "OneOnOneChatViewController.h"
#import "OneOnOneChatViewCell.h"
#import <CometChatSDK/CometChat.h>
#import <CometChatSDK/AVChat.h>
#import <CometChatSDK/AudioChat.h>
#import "NativeKeys.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <CometChatSDK/AVBroadcast.h>
#import "DBManager.h"
#import <StickersFramework/StickersFramework.h>
#import "inscriptsAppDelegate.h"

@interface OneOnOneChatViewController () {

    OneOnOneChatViewCell *chatViewCell;
    NSMutableArray *messageArray;
    CometChat *cometChat;
    AVChat *avchat;
    AudioChat *audioChat;
    AVBroadcast *avbroadcast;
    UIBarButtonItem *moreButton;
    NSObject<OS_dispatch_queue> *dispatch_queue ;
    BOOL audioFlag;
    BOOL videoFlag;
    BOOL isAVChat;
    BOOL onGoingCall;
    BOOL isTyping;
    BOOL isAVBroadcast;
    UIImage *captureImage;
    NSString *callID;
    NSString *lastCallID;
    NSString *otherCaller;
    
    /* Stickers Variables */
    BOOL hideStickerFlag;
    UIView *setFrame;
    float height;
    float yCordinate;
    
    StickersControlMethodViewController *sticker;
}

@end

@implementation OneOnOneChatViewController

@synthesize buddyName;
@synthesize buddyChannel;
@synthesize buddyID;
@synthesize buddyChatTable;
@synthesize tableViewToBottom;
@synthesize message;
@synthesize wrapper;
@synthesize sendButton;
@synthesize callReceivingWrapper, callSendingWrapper,videoView, videoContainer,controlButtons,callReceivingLabel,callSendingLabel;
@synthesize videoButtonWidth;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotifier:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotifier:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceivedNotifier:) name:@"com.inscripts.oneononechat.messagereceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageNotifier:) name:@"com.inscripts.cometchat.updatechatmessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVChatCalls:) name:@"com.demosdkproject.handleavchatcalls" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleActionMessageCalls:) name:@"com.demosdkproject.handleactionmessagecalls" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    /* Variable definition */
    messageArray = [[NSMutableArray alloc] init];
    cometChat = [[CometChat alloc] initWithAPIKey:USER_KEYS];
    avchat = [[AVChat alloc] init];
    audioChat = [[AudioChat alloc] init];
    avbroadcast = [[AVBroadcast alloc] init];
    dispatch_queue = dispatch_queue_create("queue.oneonone.imagedownload", NULL);
    callID = @"";
    otherCaller = @"0";
    /* Flag determines the call type(Audio-Video/Audio)*/
    isAVChat = NO;
    isAVBroadcast = NO;
    /* Here, NO = mute & YES = unmute */
    audioFlag = NO;
    videoFlag = NO;
    
    /* Navigation bar settings */

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.title = buddyName;
    
    /* Remove default Back button */
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-25"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_custom_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    [moreButton setStyle:UIBarButtonItemStylePlain];
    self.navigationItem.rightBarButtonItems = @[moreButton];
    /* To remove unnecessary rows */
    buddyChatTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    /* To start edge of table row without gap */
    if ([buddyChatTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [buddyChatTable setSeparatorInset:UIEdgeInsetsZero];
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
    [sendButton setTitleColor:[UIColor colorWithRed:49.0f/255.0f green:140.0f/255.0f blue:231.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
   
     for (UIButton *button in controlButtons) {
         [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         button.layer.borderColor = [UIColor whiteColor].CGColor;
         button.layer.borderWidth = 2;
         button.layer.cornerRadius = 5; // vary this value for desired rounded corner
         button.clipsToBounds = YES;
    }
    
    [[DBManager getSharedInstance] getMessages:@"0" ofUsers:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",buddyID],[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],nil] updateFlag:0];
    
    sticker = [[StickersControlMethodViewController alloc] init];
    
    [sticker getSelectedStickers:^(NSDictionary *response) {
        
        NSLog(@"Clicked stickers");
        
        [cometChat sendStickers:[NSString stringWithFormat:@"%@",[response objectForKey:@"data"]]
                         toUser:buddyID
                        success:^(NSDictionary *response){
                            
                            NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:buddyID,FROM,[response objectForKey:ID],ID,[response objectForKey:MESSAGE],MESSAGE,@"1",OLD,@1,SELF,@0,TYPE,MESSAGE_TYPE_STICKER,MESSAGE_TYPE_KEY,nil];
                            
                            long long currentTime = (long long)([[NSDate date] timeIntervalSince1970]*1000);
                            [tempDictionary setObject:[NSString stringWithFormat:@"%lld",currentTime] forKey:SENT];
                            
                            [[DBManager getSharedInstance] insertBuddyMessages:@{@"messages":tempDictionary}];
                            
                            [[DBManager getSharedInstance] getMessages:@"0" ofUsers:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",buddyID],[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],nil] updateFlag:0];
                            
                            tempDictionary = nil;
                            
                        }
                        failure:^(NSError *error){
                            
                            
                        }];
        
    }];
    
    hideStickerFlag = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    /* Store buddyID in user defaults */
    [[NSUserDefaults standardUserDefaults]setObject:buddyID forKey:CURRENT_BUDDY_ID];
    
     [callReceivingWrapper setHidden:YES];
     [callSendingWrapper setHidden:YES];
     [videoView setHidden:YES];
    onGoingCall = NO;
    isTyping = YES;
}

- (void)viewWillDisappear:(BOOL)animated{

    self.navigationItem.prompt = nil;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    /* Remove buddyID in user defaults */
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CURRENT_BUDDY_ID];
    [sticker removeStickerOberserver];
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
   
    self.tableViewToBottom.constant = convertedFrame.size.height + 50.0f;
    [buddyChatTable updateConstraintsIfNeeded];
    [buddyChatTable layoutIfNeeded];
    
    if ([messageArray count] > 0) {
        [buddyChatTable reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
        [buddyChatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"oneononechatviewcell";
    chatViewCell = [buddyChatTable dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (chatViewCell == nil) {
        chatViewCell = [[OneOnOneChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    } else {
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
    
    NSString *messageType = [NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:MESSAGE_TYPE_KEY]];
    
    UIView *wrapperView = [UIView new];
    UITextView *textView = [UITextView new];
    UIImageView *imageView = [UIImageView new];
    
    wrapperView.layer.cornerRadius = 5 ;
    wrapperView.clipsToBounds = YES;

    if ([messageType isEqualToString:MESSAGE_TYPE_IMAGE]) {
        
        CGRect imageRect = CGRectMake(4.f, 4.f, 100.f, 100.f);
        
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
        
        if ([[[messageArray objectAtIndex:indexPath.row] objectForKey:SELF] isEqual:@1]) {
            wrapperViewX = self.view.frame.size.width - imageView.frame.size.width - 14.f;
        } else {
            wrapperViewX = 7.f;
        }
        
        wrapperViewWidth = 4.f + imageView.frame.size.width + 4.f;
        wrapperViewHeight =  4.f + imageView.frame.size.height  + 4.f;
        
    } else if ([messageType isEqualToString:MESSAGE_TYPE_STICKER]) {
        
        CGRect imageRect = CGRectMake(4.f, 4.f, 100.f, 100.f);
        
        if (messageString == nil) {
            
            [imageView setImage:[UIImage imageWithData:[[messageArray objectAtIndex:indexPath.row] objectForKey:MESSAGE]]];
            
        } else {
            
            [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"StickersFramework.bundle/%@",messageString]]];
            
        }
        
        [imageView setFrame:imageRect];
        [wrapperView addSubview:imageView];
        
        if ([[[messageArray objectAtIndex:indexPath.row] objectForKey:SELF] isEqual:@1]) {
            wrapperViewX = self.view.frame.size.width - imageView.frame.size.width - 14.f;
        } else {
            wrapperViewX = 7.f;
        }
        
        wrapperViewWidth = 4.f + imageView.frame.size.width + 4.f;
        wrapperViewHeight =  4.f + imageView.frame.size.height  + 4.f;
        
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
        
        textView.frame = CGRectMake(4.0f,4.0f, sizeMessage.width, sizeMessage.height);
        
        [wrapperView addSubview:textView];
        
        if ([[[messageArray objectAtIndex:indexPath.row] objectForKey:SELF] isEqual:@1]) {
            wrapperViewX = self.view.frame.size.width - textView.frame.size.width - 14.f;
        } else {
            wrapperViewX = 7.f;
        }

        wrapperViewWidth = 4.f + textView.frame.size.width + 4.f;
        wrapperViewHeight =  4.f + textView.frame.size.height  + 4.f;
        
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
    
    UILabel *timeLabel = [UILabel new];
    UIImageView *tickImage = [UIImageView new];
    
    [timeLabel setFont:[UIFont systemFontOfSize:10.f]];
    [timeLabel setTextColor:[UIColor colorWithRed:103.0f/255.0f green:103.0f/255.0f blue:103.0f/255.0f alpha:1.0]];
    [timeLabel setNumberOfLines:0];
    [timeLabel setLineBreakMode:NSLineBreakByWordWrapping];
    NSDictionary *attributesTime = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:10.f], NSFontAttributeName, nil];
    CGRect timeRect = [timeString boundingRectWithSize:constraints options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesTime context:nil];
    CGSize sizeTime = timeRect.size;
    [timeLabel setText:timeString];
    
  
    if ([[[messageArray objectAtIndex:indexPath.row] objectForKey:SELF] isEqual:@1]) {
        
        [textView setTextColor:[UIColor whiteColor]];
        
        [wrapperView setBackgroundColor:[UIColor colorWithRed:49.0f/255.0f green:140.0f/255.0f blue:231.0f/255.0f alpha:1.0f]];
        
        [timeLabel setFrame:CGRectMake(self.view.frame.size.width - sizeTime.width - 7.f, (wrapperView.frame.origin.y + wrapperView.frame.size.height + 2.f ), sizeTime.width, sizeTime.height)];
        
    } else {
        
        [wrapperView setBackgroundColor:[UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.f]];
        
        [timeLabel setFrame:CGRectMake(7.f, (wrapperView.frame.origin.y + wrapperView.frame.size.height + 2.f ), sizeTime.width, sizeTime.height)];
        
        if (messageArray.count - 1 == indexPath.row) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [cometChat sendReadReceipt:[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"id"]] channel:buddyChannel failure:^(NSError *error) {
                    NSLog(@"sendDeliverdReceipt Error : %@",error);
                }];
                
            });
        }
        
        
    }

    if ([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"self"]] isEqualToString:@"1"]) {
        if ([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"readmsg"]] isEqualToString:@"-1"]) {
            
            [tickImage setImage:[UIImage imageNamed:@"messagetick_0"]];
            
        } else if([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"readmsg"]] isEqualToString:@"0"]) {
            
            [tickImage setImage:[UIImage imageNamed:@"messagetick_1"]];
            
        } else if([[NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:@"readmsg"]] isEqualToString:@"1"]){
            
            [tickImage setImage:[UIImage imageNamed:@"messagetick_2"]];
            
        }
    }
    
    float widthDiff = timeLabel.frame.size.height + 2;
    
    [tickImage setFrame:CGRectMake(timeLabel.frame.origin.x - widthDiff, timeLabel.frame.origin.y, timeLabel.frame.size.height, timeLabel.frame.size.height)];
    
    
    [chatViewCell.contentView addSubview:wrapperView];
    [chatViewCell.contentView addSubview:timeLabel];
    [chatViewCell.contentView addSubview:tickImage];
   
    
    timeString = nil;
    messageString = nil;
    textView = nil;
    timeLabel = nil;
    wrapperView = nil;
    tickImage = nil;
    
    return chatViewCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize constraints = CGSizeMake(((self.view.frame.size.width)*2/3 + 8.0f),100000);
    NSString *messageString = [NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:MESSAGE]];
    NSString *messageType = [NSString stringWithFormat:@"%@",[[messageArray objectAtIndex:indexPath.row] objectForKey:MESSAGE_TYPE_KEY]];
    
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
        
        return 7.f + 4.f + 100.f + 4.f + (2.f + sizeTime.height) + 2.f;
    } else {
        return 7.f + 4.f + ([textView sizeThatFits:constraints].height + 1.0f) + 4.f + (2.f + sizeTime.height) + 2.f;
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
    [buddyChatTable updateConstraintsIfNeeded];
    [buddyChatTable layoutIfNeeded];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    string = [textField.text stringByReplacingCharactersInRange:range withString:string];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (string.length == 0) {
        
        sendButton.enabled = NO;
        if (isTyping) {
            [self performSelector:@selector(callMeAfterFewSec) withObject:nil afterDelay:1.0f];
            isTyping = NO;
        }
    } else {
        
        sendButton.enabled = YES;
        if (isTyping) {
            [self performSelector:@selector(callMeAfterFewSec) withObject:nil afterDelay:6.0f];
            isTyping = NO;
        }
    }
    
    if (!isTyping) {
        NSLog(@"isTyping buddyChannel : %@",buddyChannel);
        [cometChat isTyping:YES channel:buddyChannel failure:^(NSError *error) {
            NSLog(@"SDK Log isTyping Error : %@",error);
        }];
    }
    
    return YES;
}

- (void)callMeAfterFewSec{

    [cometChat isTyping:NO channel:buddyChannel failure:^(NSError *error) {
            NSLog(@"SDK Log isTyping Error : %@",error);
    }];
    
}

- (void)handleBackButton {
    /* Pop view controller */
    if (![videoView isHidden]) {
        [videoView setHidden:YES];
        [self endCall:nil];

    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)callBuddy:(int)type {
    
    callSendingLabel.text = [NSString stringWithFormat:@"Calling %@",buddyName];
    [callSendingWrapper setHidden:NO];
    
    if (type == 1) {
        isAVChat = YES;
        isAVBroadcast = NO;
        [avchat sendAVChatRequestToUser:buddyID success:^(NSDictionary *response) {
            
            /* Here callID will be present in the response if the CometChat server version is 6+ */
            if ([response objectForKey:@"callID"]) {
                
                callID = [response objectForKey:@"callID"];
                lastCallID = callID;
            }
            NSLog(@"SDK log : AVChat send request response = %@",response);
            
        } failure:^(NSError *error) {
            [callSendingWrapper setHidden:YES];
            NSLog(@"SDK log : AVChat send request failure = %@",error);
        }];
    } else {
        isAVBroadcast = NO;
        isAVChat = NO;
        [audioChat sendAudioChatRequestToUser:buddyID success:^(NSDictionary *response) {
            
            /* Here callID will be present in the response if the CometChat server version is 6+ */
            if ([response objectForKey:@"callID"]) {
                
                callID = [response objectForKey:@"callID"];
                lastCallID = callID;
            }
            NSLog(@"SDK log : Audio Chat send request response = %@",response);
            
        } failure:^(NSError *error) {
            
            [callSendingWrapper setHidden:YES];
            NSLog(@"SDK log : Audio Chat send request failure = %@",error);
        }];
    }
}

- (void)OrientationDidChange:(NSNotification*)notification
{
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
    
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
        NSLog(@"landscape");
        dispatch_async(dispatch_get_main_queue(), ^{
            [buddyChatTable reloadData];
        });
        
    }
    else if(Orientation==UIDeviceOrientationPortrait)
    {
        NSLog(@"portrait");
        dispatch_async(dispatch_get_main_queue(), ^{
            [buddyChatTable reloadData];
        });
    }
}

- (void)showOptions {
    moreButton.enabled = NO;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (NSString *option in @[@"Make Audio Call",@"Make Audio/Video Call",@"Send Image from Path",@"Send Image-Data",@"Block User",@"Capture Image",@"Capture Video",@"Share Photo From Photo Library",@"Share Video From Photo Library",@"Share File",@"Share Audio File",@"Start Broadcast"]) {
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
            
        case 0:
            if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"callconnecterror"]] isEqualToString:@"1"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                    message:@"Please reset your network and initiate new call."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                });
            } else {
                [self callBuddy:0];
            }
            break;
        case 1:
            if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"callconnecterror"]] isEqualToString:@"1"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                    message:@"Please reset your network and initiate new call."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                });
            } else {
                [self callBuddy:1];
            }
            break;
        case 2: {
            
            /* Here, you can also give the path of image file from Document's Directory. */
            
            [cometChat sendImageWithPath:[[NSBundle mainBundle] pathForResource:@"testImage" ofType:@"jpg"] toUser:buddyID success:^(NSDictionary *response) {
                NSLog(@"SDK Log : Send Image from URL Response = %@",response);
                
                [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"sendImage Success"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.logsview.refreshLogs" object:nil];
                
                NSString *duplicateMsgIdCheck = [response objectForKey:ID];
                
                
                for(id msgDic in messageArray){
                    
                   if([[NSString stringWithFormat:@"%@",[msgDic objectForKey:ID]] isEqualToString:[NSString stringWithFormat:@"%@",duplicateMsgIdCheck]]){
                        
                        duplicateMsgIdCheck = nil;
                        return;
                    }
                }
                
                duplicateMsgIdCheck = nil;
                
                /* Get message id and message from response and form message dictionary as follows */
                NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:buddyID,FROM,[response objectForKey:ID],ID,[response objectForKey:MESSAGE],MESSAGE,@"1",OLD,@1,SELF,@0,TYPE,MESSAGE_TYPE_IMAGE,MESSAGE_TYPE_KEY,nil];
                
                long long currentTime = (long long)([[NSDate date] timeIntervalSince1970]*1000);
                [tempDictionary setObject:[NSString stringWithFormat:@"%lld",currentTime] forKey:SENT];
                
                /* Add this messageDic into messageArray and reload table */
                //[messageArray addObject:tempDictionary];
                [[DBManager getSharedInstance] insertBuddyMessages:@{@"messages":tempDictionary}];
                //        [buddyChatTable reloadData];
                [[DBManager getSharedInstance] getMessages:@"0" ofUsers:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",buddyID],[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],nil] updateFlag:0];
                //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
                //[buddyChatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                
                tempDictionary = nil;
                
            } failure:^(NSError *error) {
                NSLog(@"SDK Log : Send Image from URL Error = %@",error);
            }];
        }
            break;
        case 3: {
            
            /* Here you can also give imageData from UIImageViewController. */
            dispatch_async(dispatch_queue, ^{
                
                [cometChat sendImageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://s3.amazonaws.com/uifaces/faces/twitter/sillyleo/48.jpg"]] toUser:buddyID success:^(NSDictionary *response) {
                    
                    NSLog(@"SDK Log : Send ImageData Response = %@",response);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"sendImage Success"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.logsview.refreshLogs" object:nil];
                        
                        NSString *duplicateMsgIdCheck = [response objectForKey:ID];
                        
                        
                        for(id msgDic in messageArray){
                            
                            if([[NSString stringWithFormat:@"%@",[msgDic objectForKey:ID]] isEqualToString:[NSString stringWithFormat:@"%@",duplicateMsgIdCheck]]){
                                
                                duplicateMsgIdCheck = nil;
                                return;
                            }
                        }
                        
                        duplicateMsgIdCheck = nil;
                        
                        /* Get message id and message from response and form message dictionary as follows */
                        NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:buddyID,FROM,[response objectForKey:ID],ID,[response objectForKey:MESSAGE],MESSAGE,@"1",OLD,@1,SELF,@0,TYPE,MESSAGE_TYPE_IMAGE,MESSAGE_TYPE_KEY,nil];
                        
                        long long currentTime = (long long)([[NSDate date] timeIntervalSince1970]*1000);
                        [tempDictionary setObject:[NSString stringWithFormat:@"%lld",currentTime] forKey:SENT];
                        
                        /* Add this messageDic into messageArray and reload table */
                        //[messageArray addObject:tempDictionary];
                        //[[DBManager getSharedInstance] insertBuddyMessages:@{@"messages":tempDictionary}];
                        //        [buddyChatTable reloadData];
                        //[[DBManager getSharedInstance] getMessages:@"0" ofUsers:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",buddyID],[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],nil] updateFlag:0];
                        //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
                        //[buddyChatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        
                        tempDictionary  = nil;
                    });
                    
                    
                } failure:^(NSError *error) {
                    NSLog(@"SDK Log : Send ImageData Error = %@",error);
                }];
            });
            
            break;
        }
        case 4: {
            [cometChat blockUser:buddyID success:^(NSDictionary *response) {
                NSLog(@"Block User Response Check : %@",response);
                [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:NO];//
            } failure:^(NSError *error) {
                NSLog(@"Block User Error : %@",error);
            }];
            
            break;
        }
        case 5: {
            
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
        case 6: {
            
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
        case 7: {
            
            cameraUI.allowsEditing = YES;
            cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
            
            [self presentViewController:cameraUI animated:YES completion:nil];
            
            break;
        }
        case 8: {
            
            cameraUI.allowsEditing = NO;
            cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
            cameraUI.videoQuality = UIImagePickerControllerQualityTypeLow;
            cameraUI.wantsFullScreenLayout = YES;
            
            [self presentViewController:cameraUI animated:YES completion:nil];
            
            break;

        }
        case 9 : {
            [cometChat sendFileWithPath:[[NSBundle mainBundle] pathForResource:@"samplefile" ofType:@"txt"] toUser:buddyID success:^(NSDictionary *response) {
                NSLog(@"SDK Log : File Save response = %@",response);
                
                [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"sendFile Success"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.logsview.refreshLogs" object:nil];
                
                /* Get message id and message from response and form message dictionary as follows */
                
            } failure:^(NSError *error) {
                NSLog(@"SDK Log : Send File from URL Error = %@",error);
            }];
            
            break;
        }
        case 10 : {
            [cometChat sendAudioWithPath:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp3"] toUser:buddyID success:^(NSDictionary *response) {
                NSLog(@"SDK Log : Audio Save response = %@",response);
                
                [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"sendAudio Success"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.logsview.refreshLogs" object:nil];
                
                /* Get message id and message from response and form message dictionary as follows */
                
            } failure:^(NSError *error) {
                NSLog(@"SDK Log : Send Audio from URL Error = %@",error);
            }];
            
            break;
        }
        case 11 : {
            isAVChat = NO;
            NSLog(@"AVBroadcast Start");
            [callSendingWrapper setHidden:NO];
            [avbroadcast sendAVBroadcastRequestToUser:buddyID success:^(NSDictionary *response) {
                isAVBroadcast = YES;
                NSLog(@"avbroadcast response : %@",response);
                callID = [NSString stringWithFormat:@"%@",[response objectForKey:@"callID"]];
                NSLog(@"Call ID AVBroadcast : %@",callID);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [callSendingWrapper setHidden:YES];
                    [videoView setHidden:NO];
                    [avbroadcast startAVBroadcastWithInitiator:YES callID:callID containerView:videoContainer connectedUser:^(NSDictionary *response) {
                        [videoView setHidden:NO];
                        NSLog(@"SDK Log Response : %@",response);
                        
                    } changeInAudioRoute:^(NSDictionary *audioroute) {
                        NSLog(@"SDK Log Change Audio Route : %@",audioroute);
                    } failure:^(NSError *error) {
                        NSLog(@"SDK Log Error : %@",error);
                    }];
                });
                
            } failure:^(NSError *error) {
                [callSendingWrapper setHidden:YES];
                NSLog(@"AVBroadcast Error : %@",error);
            }];
            
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                                   if([info valueForKey:UIImagePickerControllerEditedImage] && [info valueForKey:UIImagePickerControllerEditedImage] != [NSNull null]){
                                       captureImage = [info valueForKey:UIImagePickerControllerEditedImage];
                                       
                                       NSData *data = UIImageJPEGRepresentation(captureImage, 0.6);
                                       [cometChat sendImageWithData:data toUser:buddyID success:^(NSDictionary *response) {
                                           
                                           NSLog(@"SDK Log : Send ImageData Response = %@",response);
                                           
                                           [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"sendImage Success"];
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.logsview.refreshLogs" object:nil];
                                           
                                           /* Get message id and message from response and form message dictionary as follows */
                                           NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:buddyID,FROM,[response objectForKey:ID],ID,[response objectForKey:MESSAGE],MESSAGE,@"1",OLD,@1,SELF,@0,TYPE,MESSAGE_TYPE_IMAGE,MESSAGE_TYPE_KEY,nil];
                                           
                                           long long currentTime = (long long)([[NSDate date] timeIntervalSince1970]*1000);
                                           [tempDictionary setObject:[NSString stringWithFormat:@"%lld",currentTime] forKey:SENT];
                                           
                                           /* Add this messageDic into messageArray and reload table */
                                           //[messageArray addObject:tempDictionary];
                                           [[DBManager getSharedInstance] insertBuddyMessages:@{@"messages":tempDictionary}];
                                           //        [buddyChatTable reloadData];
                                           [[DBManager getSharedInstance] getMessages:@"0" ofUsers:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",buddyID],[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],nil] updateFlag:0];
                                           //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
                                           //[buddyChatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                                           
                                           tempDictionary = nil;
                                           
                                       } failure:^(NSError *error) {
                                           
                                       }];
                                   } else {
                                       
                                       NSURL *videoURL = [info valueForKey:UIImagePickerControllerMediaURL];
                                       NSString *pathToVideo = [videoURL path];
                                       BOOL okToSaveVideo = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToVideo);
                                       if (okToSaveVideo) {
                                           //UISaveVideoAtPathToSavedPhotosAlbum(pathToVideo, self, @selector(reseting), NULL);
                                           
                                           [cometChat sendVideoWithURL:videoURL toUser:buddyID success:^(NSDictionary *response) {
                                               NSLog(@"SDK Log : Video Save response = %@",response);
                                               
                                               [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"sendVideo Success"];
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.logsview.refreshLogs" object:nil];
                                               
                                               /* Get message id and message from response and form message dictionary as follows */
                                               
                                               
                                               
                                           } failure:^(NSError *error) {
                                               NSLog(@"SDK Log : Video Save Error : %@",error);
                                           }];
                                       } else {
                                           NSLog(@"Some Error While video save on video path");
                                       }
                                   }
                                   
                                   
                                   /* Select Image from Camera or PhotoLibrary and Reduce Quality */
 
                               }];
}

#pragma mark - Notification Handlers
/* Notification handler for one on one chat*/
- (void)messageReceivedNotifier: (NSNotification *)notification {
    
    /* Check if it is not self message */
//    if (self.isViewLoaded && self.view.window) {
//        
//        NSString *duplicateMsgIdCheck = [[notification userInfo] objectForKey:ID];
//        
//        NSDictionary *dic = nil;
//        for(id msgDic in messageArray){
//        
//            dic = msgDic;
//            if([[NSString stringWithFormat:@"%@",[msgDic objectForKey:ID]] isEqualToString:[NSString stringWithFormat:@"%@",duplicateMsgIdCheck]]){
//                
//                duplicateMsgIdCheck = nil;
//                return;
//            }
//        }
//        
//                if ([[notification userInfo] objectForKey:MESSAGE_TYPE_KEY]) {
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
//            }
//            else if (![messageType isEqualToString:MESSAGE_TYPE_STANDARD] && ![messageType isEqualToString:MESSAGE_TYPE_IMAGE]) {
//                [messageDictionary setObject:[NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:@"message"]]  forKey:@"message"];
//                messageType = nil;
//                messageDictionary = nil;
//                return;
//            }
//            
//            [messageArray addObject:messageDictionary];
//            [buddyChatTable reloadData];
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
//            [buddyChatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//            
//            messageType = nil;
//            messageDictionary = nil;
//        }
//    }
    
    [[DBManager getSharedInstance] getMessages:@"0" ofUsers:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",buddyID],[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],nil] updateFlag:0];
    
}

- (void)updateMessageNotifier:(NSNotification *)notification{
    
    if ([[[notification userInfo] objectForKey:@"TAG"] isEqualToString:@"0"]) {
        
        messageArray = nil;
        
        messageArray = [[notification userInfo] objectForKey:@"data"];
        
        if ([messageArray count] > 0) {
            
            /* Update indexes of timelabel messages */
            
            [buddyChatTable reloadData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
            [buddyChatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        
    }
    
}

- (void)handleAVChatCalls:(NSNotification *)notification {
    
    if ([notification userInfo]) {
        
        if (self.isViewLoaded && self.view.window) {
           
            isAVChat = [[[notification userInfo] objectForKey:@"pluginType"] integerValue];
            
            switch ([[[notification userInfo] objectForKey:MESSAGE_TYPE_KEY] integerValue]) {
                case 31: {
                    otherCaller = @"0";
                    [callSendingWrapper setHidden:YES];
                    [videoView setHidden:NO];
                    callID = [NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:@"callID"]];
                    lastCallID = callID;
                    if (isAVChat) {
                        
                            videoButtonWidth.constant = 50.0f;
                            dispatch_async(dispatch_get_main_queue(), ^{
                            [avchat startAVChatWithCallID:[NSString stringWithFormat:@"%@",callID] containerView:videoContainer connectedUser:^(NSDictionary *response) {
                                NSLog(@"SDK Log : Connected user response = %@ ",response);
                                
                            }  changeInAudioRoute:^(NSDictionary *audioRouteInformation) {
                                NSLog(@"SDK Log : Audio route change = %@",audioRouteInformation);
                            } failure:^(NSError *error) {
                                
                                dispatch_async(dispatch_get_main_queue(),^{
                                    
                                    NSLog(@"SDK Log : %@",error);

                                });
                               
                            }];
                            });
                       
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            videoButtonWidth.constant = 0.0f;
                            [audioChat startAudioChatWithCallID:[NSString stringWithFormat:@"%@",callID] containerView:videoContainer connectedUser:^(NSDictionary *response) {
                                
                                NSLog(@"SDK Log : Connected user response = %@ ",response);
                                
                            } changeInAudioRoute:^(NSDictionary *audioRouteInformation) {
                                
                                NSLog(@"SDK Log : Audio route change = %@",audioRouteInformation);
                                
                            } failure:^(NSError *error) {
                                dispatch_async(dispatch_get_main_queue(),^{
                                    
                                    NSLog(@"%@",error);
                                });
                            }];
                        });
                    }
                    
                }
                    break;
                    
                case 32:
                    
                    if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"callconnecterror"]] isEqualToString:@"1"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                            message:@"Please reset your network and initiate new call."
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        });
                    } else {
                        
                        callReceivingLabel.text = [NSString stringWithFormat:@"Incoming call from %@",buddyName];
                        callID = [NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:@"callID"]];
                        lastCallID = callID;
                        [callReceivingWrapper setHidden:NO];
                        [self performSelector:@selector(timeoutActivityForIncomingCall) withObject:self afterDelay:30];
                    
                    }
                    break;
                    
                case 33:
                    
                    if (isAVChat) {
                        
                        [avchat sendBusyCallToUser:[NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:FROM]] success:^(NSDictionary *response) {
                            NSLog(@"SDK log : Busy call response = %@,",response);
                        } failure:^(NSError *error) {
                            NSLog(@"SDK log : Busy call error = %@,",error);
                        }];
                        
                    } else {
                        
                        [audioChat sendBusyCallToUser:[NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:FROM]] success:^(NSDictionary *response) {
                            NSLog(@"SDK log : Busy call response = %@,",response);
                        } failure:^(NSError *error) {
                            NSLog(@"SDK log : Busy call error = %@,",error);
                        }];
                    }
                   
                    break;
                    
                case 34:
                    
                    [videoView setHidden:YES];
                    
                    break;
                    
                case 35:
                    [callSendingWrapper setHidden:YES];
                    
                    break;
                    
                case 36:
                    [callReceivingWrapper setHidden:YES];
                    [videoView setHidden:YES];
                    
                    break;
                case 37:
                    [callSendingWrapper setHidden:YES];
                    
                    break;
                    
                case 38:
                    [callSendingWrapper setHidden:YES];
                    
                    break;
                case 41:{
                    [callSendingWrapper setHidden:YES];
                    isAVBroadcast = YES;
                    isAVChat = NO;
                    callID = [NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:@"callID"]];
                    NSLog(@"AVBroadcast Accept : %@",callID);
                    //[avbroadcast acceptAVBroadcastRequestOfUser:buddyID callID:callID success:^(NSDictionary *response) {
                        [videoView setHidden:NO];
                        [avbroadcast startAVBroadcastWithInitiator:NO callID:callID containerView:videoContainer connectedUser:^(NSDictionary *response) {
                            
                            NSLog(@"SDK Log avbroadcaststart : %@",response);
                        } changeInAudioRoute:^(NSDictionary *audioRoute) {
                            NSLog(@"SDK Log avbroadcastaudioroute : %@",audioRoute);
                        } failure:^(NSError *error) {
                            [videoView setHidden:YES];
                            NSLog(@"SDK Log avbroadcasterror : %@",error);
                        }];
                     //   NSLog(@"SDK Log accpet Response : %@",response);
                    //} failure:^(NSError *error) {
                    //    NSLog(@"SDK Log accept Error : %@",error);
                    //}];
                }
                default:
                    break;
            }
        }
    }
}

- (void)handleActionMessageCalls:(NSNotification *)notification{
    
    if ([[NSString stringWithFormat:@"%@",buddyID] isEqualToString:[NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:@"from"]]]) {
        
        if ([[[notification userInfo] objectForKey:@"action"] isEqualToString:@"typing_start"]) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.prompt = @"typing...";
            });
            
        } else if([[[notification userInfo] objectForKey:@"action"] isEqualToString:@"typing_stop"]){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.prompt = nil;
            });
            
        }  else if([[[notification userInfo] objectForKey:@"action"] isEqualToString:@"message_deliverd"]){
            
            
            for (id msgDic in messageArray) {
                
                
                
                if ([[msgDic objectForKey:@"id"] intValue] == [[[notification userInfo] objectForKey:@"message_id"] intValue] && [[NSString stringWithFormat:@"%@",[msgDic objectForKey:@"readmsg"]] isEqualToString:@"-1"]) {
                    
                    [[DBManager getSharedInstance] updateDeliveryReadMsg:[NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:@"message_id"]] readFlag:@"0" userid:buddyID];
                    
                    [[DBManager getSharedInstance] getMessages:@"0" ofUsers:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",buddyID],[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],nil] updateFlag:0];
                    
                }
                
                
            }
            
            
            
        } else if([[[notification userInfo] objectForKey:@"action"] isEqualToString:@"message_read"]){
            
            for (id msgDic in messageArray) {
                
                if ([[msgDic objectForKey:@"id"] intValue] == [[[notification userInfo] objectForKey:@"message_id"] intValue] && ![[NSString stringWithFormat:@"%@",[msgDic objectForKey:@"readmsg"]] isEqualToString:@"1"]){
                    
                    [[DBManager getSharedInstance] updateDeliveryReadMsg:[NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:@"message_id"]] readFlag:@"1" userid:buddyID];
                    
                    [[DBManager getSharedInstance] getMessages:@"0" ofUsers:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",buddyID],[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],nil] updateFlag:0];
                    
                } else if([[[notification userInfo] objectForKey:@"message_id"] intValue] == 0 && ![[NSString stringWithFormat:@"%@",[msgDic objectForKey:@"readmsg"]] isEqualToString:@"1"]){
                    
                    [[DBManager getSharedInstance] updateDeliveryReadMsg:[NSString stringWithFormat:@"%@",[[notification userInfo] objectForKey:@"message_id"]] readFlag:@"2" userid:buddyID];
                    
                    [[DBManager getSharedInstance] getMessages:@"0" ofUsers:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",buddyID],[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],nil] updateFlag:0];
                    
                }
                
            }
            
            
            
        }
        
    }
    
}

- (void)timeoutActivityForIncomingCall{
    
    /* Dismiss the call receiving view  */
    if (!callReceivingWrapper.hidden) {
        
        [callReceivingWrapper setHidden:YES];
        
        if (isAVChat) {
            [avchat sendNoAnswerCallOfUser:buddyID callID:[NSString stringWithFormat:@"%@",callID] success:^(NSDictionary *response) {
                
                NSLog(@"SDK log : No answer to  call response = %@,",response);
            } failure:^(NSError *error) {
                
                NSLog(@"SDK log : No answer to call error = %@,",error);
            }];
        } else {
            [audioChat sendNoAnswerCallOfUser:buddyID callID:[NSString stringWithFormat:@"%@",callID] success:^(NSDictionary *response) {
                
                NSLog(@"SDK log : No answer to  call response = %@,",response);
            } failure:^(NSError *error) {
                
                NSLog(@"SDK log : No answer to call error = %@,",error);
            }];
        }
        
    }
}

#pragma mark - IBAction
- (IBAction)sendMessage:(id)sender
{
    [cometChat isTyping:NO channel:buddyChannel failure:^(NSError *error) {
            NSLog(@"SDK Log isTyping Error : %@",error);
    }];
    message.text = [message.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

     /* Send message to user, specify userID */
    [cometChat sendMessage:message.text toUser:self.buddyID success:^(NSDictionary *response) {
        
        /* Send message success block */
        
        NSLog(@"SDK log : OneOnOne messageSent %@",response);
        
        [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"sendMessage Success"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.logsview.refreshLogs" object:nil];
        
        NSString *duplicateMsgIdCheck = [response objectForKey:ID];
        
        
        for(id msgDic in messageArray){
            
            if([[NSString stringWithFormat:@"%@",[msgDic objectForKey:ID]] isEqualToString:[NSString stringWithFormat:@"%@",duplicateMsgIdCheck]]){
                
                duplicateMsgIdCheck = nil;
                return;
            }
        }
        
        duplicateMsgIdCheck = nil;
        
        /* Get message id and message from response and form message dictionary as follows */
        NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:buddyID,FROM,[response objectForKey:ID],ID,[response objectForKey:SENT_MESSAGE],MESSAGE,@"1",OLD,@1,SELF,@0,TYPE,nil];
        long long currentTime = (long long)([[NSDate date] timeIntervalSince1970]*1000);
        [tempDictionary setObject:[NSString stringWithFormat:@"%lld",currentTime] forKey:SENT];
        
        /* Add this messageDic into messageArray and reload table */
//        [messageArray addObject:tempDictionary];
        [[DBManager getSharedInstance] insertBuddyMessages:@{@"messages":tempDictionary}];
//        [buddyChatTable reloadData];
        [[DBManager getSharedInstance] getMessages:@"0" ofUsers:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%@",buddyID],[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]],nil] updateFlag:0];
        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
//        [buddyChatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
        tempDictionary = nil;
        
    } failure:^(NSError *error) {
        NSLog(@"SDK log : OneOnOne messageSent :error %@",error);
        
        [NativeKeys getLogOType:LOG_TYPE_ONE_ON_ON ForMessage:@"sendMessage failure"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.logsview.refreshLogs" object:nil];
    }];
    message.text = @"";
    sendButton.enabled = NO;
}

#pragma - mark AVChat IBAction methods
- (IBAction)cancelCall:(id)sender {
    
    if (isAVChat) {
        
        [avchat cancelAVChatRequestWithUser:buddyID success:^(NSDictionary *response) {
            
            [callSendingWrapper setHidden:YES];
            
            NSLog(@"SDK log : AVChat cancel call response = %@ ",response);
            
        } failure:^(NSError *error) {
            
            NSLog(@"SDK log : AVChat cancel call failed = %@ ",error);
        }];
    } else {
        [audioChat cancelAudioChatRequestWithUser:buddyID success:^(NSDictionary *response) {
            
            [callSendingWrapper setHidden:YES];
            
            NSLog(@"SDK log : Audio Chat cancel call response = %@ ",response);
            
        } failure:^(NSError *error) {
            
            NSLog(@"SDK log : Audio Chat cancel call failed = %@ ",error);
        }];
    }
    
}

- (IBAction)acceptCall:(id)sender {
    onGoingCall = YES;
    otherCaller = @"1";
    
    if ([[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"callconnecterror"]] isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Please reset your network and initiate new call."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    } else {
        if (isAVChat) {
            isAVBroadcast = NO;
            [avchat acceptAVChatRequestOfUser:[NSString stringWithFormat:@"%@",buddyID] callID:[NSString stringWithFormat:@"%@",callID] success:^(NSDictionary *response) {
                
                [callReceivingWrapper setHidden:YES];
                [videoView setHidden:NO];
                
                videoButtonWidth.constant = 50.0f;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [avchat startAVChatWithCallID:[NSString stringWithFormat:@"%@",callID] containerView:videoContainer  connectedUser:^(NSDictionary *response) {
                        NSLog(@"SDK log : Connected user response = %@ ",response);
                        
                    }  changeInAudioRoute:^(NSDictionary *audioRouteInformation) {
                        
                        NSLog(@"SDK Log : Audio route change = %@",audioRouteInformation);
                        
                    } failure:^(NSError *error) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [videoView setHidden:YES];
                        });
                        
                    }];
                });
                NSLog(@"SDK log : AVChat accept call response = %@ ",response);
                
            } failure:^(NSError *error) {
                NSLog(@"SDK log : AVChat accept call failed = %@ ",error);
            }];
        } else {
            isAVBroadcast = NO;
            [audioChat acceptAudioChatRequestOfUser:[NSString stringWithFormat:@"%@",buddyID] callID:[NSString stringWithFormat:@"%@",callID] success:^(NSDictionary *response) {
                
                [callReceivingWrapper setHidden:YES];
                [videoView setHidden:NO];
                
                videoButtonWidth.constant = 0.0f;
                
                [audioChat startAudioChatWithCallID:[NSString stringWithFormat:@"%@",callID] containerView:videoContainer connectedUser:^(NSDictionary *response) {
                    
                    NSLog(@"SDK Log : Connected user response = %@ ",response);
                    
                } changeInAudioRoute:^(NSDictionary *audioRouteInformation) {
                    
                    NSLog(@"SDK Log : Audio route change = %@",audioRouteInformation);
                    
                } failure:^(NSError *error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"Call End Due To Error");
                        [self endCall:nil];
                    });
                }];
                
                NSLog(@"SDK log : Audio Chat accept call response = %@ ",response);
                
            } failure:^(NSError *error) {
                NSLog(@"SDK log : Audio Chat accept call failed = %@ ",error);
            }];
        }
    }
    
    
}

- (IBAction)rejectCall:(id)sender {
    
    if (isAVChat) {
        
        [avchat rejectAVChatRequestOfUser:buddyID callID:[NSString stringWithFormat:@"%@",callID] success:^(NSDictionary *response) {
            
            [callReceivingWrapper setHidden:YES];
            
            NSLog(@"SDK log : AVChat reject call response = %@ ",response);
            
        } failure:^(NSError *error) {
            
            NSLog(@"SDK log : AVChat reject call failed = %@ ",error);
        }];
    } else {
        
        [audioChat rejectAudioChatRequestOfUser:buddyID callID:[NSString stringWithFormat:@"%@",callID] success:^(NSDictionary *response) {
            
            [callReceivingWrapper setHidden:YES];
            
            NSLog(@"SDK log : Audio Chat reject call response = %@ ",response);
            
        } failure:^(NSError *error) {
            
            NSLog(@"SDK log : Audio Chat reject call failed = %@ ",error);
        }];
    }
}

- (IBAction)endCall:(id)sender {
    
    if (isAVChat) {
        
        [avchat endAVChatWithUser:[NSString stringWithFormat:@"%@",buddyID] callID:[NSString stringWithFormat:@"%@",callID] success:^(NSDictionary *response) {
            [videoView setHidden:YES];
            NSLog(@"SDK log : AVChat end call response = %@ ",response);
            
        } failure:^(NSError *error) {
            
            NSLog(@"SDK log : AVChat end call failed = %@ ",error);
        }];
    } else if(isAVBroadcast){
        [avbroadcast endAVBroadcastWithUser:buddyID callID:callID success:^(NSDictionary *response) {
            [videoView setHidden:YES];
            NSLog(@"SDK Log AVBroadcast End Response: %@",response);
        } failure:^(NSError *error) {
            NSLog(@"SDK Log AVBroadcast End Error : %@",error);
        }];
    } else {
        
            
            [audioChat endAudioChatWithUser:[NSString stringWithFormat:@"%@",buddyID] callID:[NSString stringWithFormat:@"%@",callID] success:^(NSDictionary *response) {
                
                [videoView setHidden:YES];
                
                NSLog(@"SDK log : Audio Chat end call response = %@ ",response);
                
            } failure:^(NSError *error) {
                
                NSLog(@"SDK log : Audio Chat end call failed = %@ ",error);
                
            }];
        
    }
    
}

- (IBAction)toggleAudio:(id)sender {
    
    [avchat toggleAudio:audioFlag];
    
    if (audioFlag == NO) {
        
        audioFlag = YES;
        
    } else {
        
        audioFlag = NO;
    }
}

- (IBAction)switchAudioRoute:(id)sender {
    
    [avchat switchAudioRoute];
}

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
        [buddyChatTable updateConstraintsIfNeeded];
        [buddyChatTable layoutIfNeeded];
    }
    
}

- (IBAction)toggleVideo:(id)sender {
    
    [avchat toggleVideo:videoFlag];
    
    if (videoFlag == NO) {
        
        videoFlag = YES;
        
    } else {
        videoFlag = NO;
    }
}
@end
