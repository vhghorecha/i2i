//
//  MainViewController.h
//  SDKTestApp
//
//  Created by Inscripts on 03/10/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UIActionSheetDelegate>


@property (weak, nonatomic) IBOutlet UIButton *oneOnOneButton;
@property (weak, nonatomic) IBOutlet UIButton *chatroomButton;
@property (weak, nonatomic) IBOutlet UIButton *logButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;


- (IBAction)openOneOnOneList:(id)sender;

- (IBAction)openChatroomList:(id)sender;
- (IBAction)showLogs:(id)sender;
- (IBAction)logout:(id)sender;

@end
