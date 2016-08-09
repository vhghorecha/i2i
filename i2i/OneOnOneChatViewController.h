//
//  OneOnOneChatViewController.h
//  SDKTestApp
//
//  Created by Inscripts on 30/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OneOnOneChatViewController : UIViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSString *buddyID;
@property (strong,nonatomic) NSString *buddyName;
@property (strong,nonatomic) NSString *buddyChannel;
@property (weak, nonatomic) IBOutlet UITableView *buddyChatTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewToBottom;
@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UIView *wrapper;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

//AVChat Outlets
@property (weak, nonatomic) IBOutlet UIView *callSendingWrapper;
@property (weak, nonatomic) IBOutlet UIView *callReceivingWrapper;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIView *videoContainer;
@property (weak, nonatomic) IBOutlet UILabel *callReceivingLabel;
@property (weak, nonatomic) IBOutlet UILabel *callSendingLabel;
@property IBOutletCollection(UIButton) NSArray *controlButtons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoButtonWidth;

- (IBAction)sendMessage:(id)sender;
- (void)sendImage;

//AVChat actions
- (IBAction)cancelCall:(id)sender;
- (IBAction)acceptCall:(id)sender;
- (IBAction)rejectCall:(id)sender;
- (IBAction)endCall:(id)sender;
- (IBAction)toggleVideo:(id)sender;
- (IBAction)toggleAudio:(id)sender;
- (IBAction)switchAudioRoute:(id)sender;
- (IBAction)stickerKeyboardAction:(id)sender;

@end
