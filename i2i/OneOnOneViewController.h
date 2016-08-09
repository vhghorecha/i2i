//
//  OneOnOneViewController.h
//  SDKTestApp
//
//  Created by Inscripts on 29/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneOnOneViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *buddyListTable;
@property (weak, nonatomic) IBOutlet UILabel *unblockUserLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unblockUserLabelHeight;


@end
