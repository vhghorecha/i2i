//
//  LogsViewController.h
//  SDKTestApp
//
//  Created by Inscripts on 03/10/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *logListTable;

@end
