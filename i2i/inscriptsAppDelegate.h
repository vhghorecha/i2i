//
//  inscriptsAppDelegate.h
//  SDKTestApp
//
//  Created by Inscripts on 29/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SHARED_APPDELEGATE [inscriptsAppDelegate sharedAppDelegate]
#define LOGIN_USER_ID @"loginuserid"


#define USER_KEYS @"b88fd407ee8cdb4af8221489fce05a20"
#define SITE_URL @"http://i2iapp.com/ichat/"
#define API_URL SITE_URL @"api/index.php"

@interface inscriptsAppDelegate : UIResponder <UIApplicationDelegate>

{
    UIView *loadView;
    UIView *viewBack;
    UILabel *lblLoading;
    UIActivityIndicatorView *spinningWheel;
}

@property (strong, nonatomic) UIWindow *window;

+(inscriptsAppDelegate*)sharedAppDelegate;

-(NSString*) trimString:(NSString *)theString;
-(NSString *)applicationCacheDirectory;

-(void)showLoadingView;
-(void) hideLoadingView;

-(void)showAlertWithTitle:(NSString *)strTitle andMessage:(NSString *)strMessage delegate:(id)delegate;

@end
