//
//  VideoChatViewController.h
//  SDKTestApp
//
//  Created by Inscripts on 06/04/15.
//  Copyright (c) 2015 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CometChatSDK/GroupAVChat.h>

@interface VideoChatViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *videoView;
- (IBAction)endAction:(id)sender;

@end
