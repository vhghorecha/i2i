//
//  OneOnOneListViewCell.h
//  SDKTestApp
//
//  Created by Inscripts on 29/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneOnOneListViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *buddyAvatar;
@property (weak, nonatomic) IBOutlet UILabel *buddyName;
@property (strong, nonatomic) NSString *buddyID;
@property (strong, nonatomic) NSString *buddyChannel;
@property (weak, nonatomic) IBOutlet UILabel *statusMessage;
@property (weak, nonatomic) IBOutlet UIImageView *statusIcon;

@end
