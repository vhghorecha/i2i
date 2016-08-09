//
//  inscriptsAppDelegate.m
//  SDKTestApp
//
//  Created by Inscripts on 29/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import "inscriptsAppDelegate.h"
#import "PushNotification.h"

@implementation inscriptsAppDelegate

+(inscriptsAppDelegate*)sharedAppDelegate
{
    return (inscriptsAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(NSString *)applicationCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    /* Push notification Registration */
    [PushNotification registerParse];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
        
    } else {
        
        [application registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken with devicetoken : %@",deviceToken);
    if (deviceToken != nil) {
        NSLog(@"registering for push notification");
        [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"devicetoken"];
        [PushNotification registerDeviceToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"devicetoken"]];
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"PUSH NOTIFICATION DATA1 = %@",userInfo);
    NSLog(@"PUSH NOTIFICATION DATA2 = %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"devicetoken"]);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"devicetoken"] != nil) {
        
        NSLog(@"PUSH NOTIFICATION DATA1 = %@",userInfo);
        [PFPush handlePush:userInfo];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
        
    }
    
    //[[UAPush shared] resetBadge];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"PUSH NOTIFICATION DATA2 = %@",userInfo);
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    currentInstallation.badge = 0;
    [currentInstallation saveEventually];
    
    
    if (application.applicationState != UIApplicationStateActive) {
        
        if (userInfo != nil) {
            
            
            
        }
        else{
            NSLog(@"NULL DATA IN APP LAUNCH");
        }
        
        
    }
    completionHandler(UIBackgroundFetchResultNoData);
    
}

-(void)showLoadingView
{
    
    if (loadView == nil)
    {
        loadView = [[UIView alloc] initWithFrame:self.window.frame];
        loadView.opaque = NO;
        loadView.backgroundColor = [UIColor clearColor];
        //loadView.alpha = 0.7f;
        
        viewBack = [[UIView alloc] initWithFrame:CGRectMake(80, 230, 160, 50)];
        viewBack.backgroundColor = [UIColor blackColor];
        viewBack.alpha = 0.7f;
        viewBack.layer.masksToBounds = NO;
        viewBack.layer.cornerRadius = 5;
        
        lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 110, 50)];
        lblLoading.backgroundColor = [UIColor clearColor];
        lblLoading.textAlignment = NSTextAlignmentCenter;
        lblLoading.text = @"Please Wait...";
        lblLoading.numberOfLines = 2;
        
        spinningWheel = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(5.0, 10.0, 30.0, 30.0)];
        spinningWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        lblLoading.textColor = [UIColor whiteColor];
        [spinningWheel startAnimating];
        [viewBack addSubview:spinningWheel];
        
        //lblLoading.font = FONT_REGULAR(16);
        [viewBack addSubview:lblLoading];
        [loadView addSubview:viewBack];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            float y = (loadView.frame.size.height/2 ) - (viewBack.frame.size.height/2);
            float x =(loadView.frame.size.width/2 ) - (viewBack.frame.size.width/2);
            viewBack.frame = CGRectMake(x , y, 160, 50);;
        }
        else{
            
            float y = (loadView.frame.size.height/2 ) - (viewBack.frame.size.height/2);
            float x =(loadView.frame.size.width/2 ) - (viewBack.frame.size.width/2);
            viewBack.frame = CGRectMake(x , y, 160, 50);;
        }
    }
    if(loadView.superview == nil)
        [self.window addSubview:loadView];
}
-(void) hideLoadingView
{
    [loadView removeFromSuperview];
    loadView=nil;
}


-(void)showAlertWithTitle:(NSString *)strTitle andMessage:(NSString *)strMessage delegate:(id)delegate
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Alert!"
                                          message:strMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       
                                   }];
    [alertController addAction:cancelAction];
    [delegate presentViewController:alertController animated:YES completion:nil];
}

@end