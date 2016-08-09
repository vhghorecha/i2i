//
//  ChatroomViewController.h
//  SDKTestApp
//
//  Created by Inscripts on 29/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatroomViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *chatRoomListTable;
@property (weak, nonatomic) IBOutlet UIButton *getChatroomList;
- (IBAction)getChatroomList:(id)sender;


@end
