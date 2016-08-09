//
//  LogsViewController.m
//  SDKTestApp
//
//  Created by Inscripts on 03/10/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import "LogsViewController.h"
#import "LogsTableViewCell.h"
#import "NativeKeys.h"


@interface LogsViewController () {

    LogsTableViewCell *logCell;
    /* logList array to store logs */
    NSMutableArray *logList;
}

@end

@implementation LogsViewController
@synthesize logListTable;


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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLogs) name:@"com.inscripts.logsview.refreshLogs" object:nil];
    
    /* Variable Initialization */
    logList = [[NSMutableArray alloc] init];
    
    /* Navigation bar settings */
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:49.0f/255.0f green:140.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.title = @"Logs";
    
    /* Remove default Back button */
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-25"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    /* To start edge of table row without gap */
    if ([logListTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [logListTable setSeparatorInset:UIEdgeInsetsZero];
    }
    
    /* To remove unnecessary rows */
    logListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    /* Updated buddylist with buddyList in userdefaults */
    if ([[NSUserDefaults standardUserDefaults] objectForKey:LOG_LIST]) {
        [logList addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:LOG_LIST]];
    }
    
    
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [logList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"logstableviewcell" ;
  
    //NSLog(@"buddy data in cell = %@",buddyData);
    logCell = [logListTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (logCell == nil) {
        logCell = [[LogsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    /* Show buddy name in cell */
    logCell.logText.text = [logList objectAtIndex:indexPath.row];
    
    return logCell;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    
    switch (section) {
            
        case 0: return @"  No Logs to display.";
            break;
            
        default:
            break;
    }
    return @"";
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if ([logList count] == 0) {
                return 44.0f;
            }
            break;
            
        default:
            break;
    }
    return 0.0f;
}




/* Notification handler for one on one chat*/
-(void) refreshLogs
{
    [logList removeAllObjects];
    /* Refresh buddyList with updated buddylist in userdefaults */
    [logList addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:LOG_LIST]];
    
    [logListTable reloadData];
}

-(void)handleBackButton
{
    /* Pop view controller */
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
