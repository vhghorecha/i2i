//
//  ChatroomChatViewController.h
//  SDKTestApp
//
//  Created by Inscripts on 30/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatroomChatViewController : UIViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *chatTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewToBottom;
@property (weak, nonatomic) IBOutlet UITextField *message;

@property (weak, nonatomic) IBOutlet UIView *wrapper;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) NSString *currentRoomID;
@property (strong, nonatomic) NSString *currentRoomName;

- (IBAction)sendMessage:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *callReceivingWrapper;
- (IBAction)acceptAction:(id)sender;
- (IBAction)rejectAction:(id)sender;
- (IBAction)stickerKeyboardAction:(id)sender;

@end
