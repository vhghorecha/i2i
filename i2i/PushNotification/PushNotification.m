//
//  PushNotification.m
//  CometChat
//
//  Created by Inscripts on 28/05/14.
//  Copyright (c) 2014 Inscripts. All rights reserved.
//

#import "PushNotification.h"

PFInstallation *currentInstallation;
@implementation PushNotification

+ (void)registerParse {
    
    NSLog(@"Registration called");
    NSString *applicationID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Application ID"];
    NSString *clientKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Client Key"];
   
    [Parse setApplicationId:applicationID clientKey:clientKey];
    currentInstallation = [PFInstallation currentInstallation];
}

+ (void)registerDeviceToken:(NSData *)deviceToken {
    
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    NSLog(@"DEVICE TOKEN IS = %@",deviceToken);
}

+ (void)subscribeToParseChannel:(NSString *)channelName {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"devicetoken"]){
        
        if ([currentInstallation objectForKey:@"channels"]) {
            
            [currentInstallation addUniqueObject:channelName forKey:@"channels"];
        } else {
            [currentInstallation setObject:@[channelName] forKey:@"channels"];
        }

        [currentInstallation saveInBackground];
    }
}

+ (void)subscribeAllParseChannel {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"devicetoken"]){
        
        // currentInstallation = [PFInstallation currentInstallation];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"parsesubscribeduserchannel"]) {
            
            if ([currentInstallation objectForKey:@"channels"]) {
                
                [currentInstallation addUniqueObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"parsesubscribeduserchannel"] forKey:@"channels"];
            } else {
                [currentInstallation setObject:@[[[NSUserDefaults standardUserDefaults] objectForKey:@"parsesubscribeduserchannel"]] forKey:@"channels"];
            }
        }
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"parsesubscribedchatroomchannel"]) {
            
            if ([currentInstallation objectForKey:@"channels"]) {
                
                [currentInstallation addUniqueObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"parsesubscribedchatroomchannel"] forKey:@"channels"];
            } else {
                [currentInstallation setObject:@[[[NSUserDefaults standardUserDefaults] objectForKey:@"parsesubscribedchatroomchannel"]] forKey:@"channels"];
            }
        }
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"parsesubscribedannouncementchannel"]) {
            
            if ([currentInstallation objectForKey:@"channels"]) {
                [currentInstallation addUniqueObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"parsesubscribedannouncementchannel"] forKey:@"channels"];
            } else {
                [currentInstallation setObject:@[[[NSUserDefaults standardUserDefaults] objectForKey:@"parsesubscribedannouncementchannel"]] forKey:@"channels"];
            }
        }
        [currentInstallation saveInBackground];
    }
}
//+ (NSArray *)getAllSubscribedChannels
//{
//    NSArray *subscribedChannels ;
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]){
//       subscribedChannels = [PFInstallation currentInstallation].channels;
//    }
//    
//    return subscribedChannels;
//}

+ (void)unsubscribeParseChannel:(NSString *)channelName {
    
    NSLog(@"unsubscribe parse channel = %@",channelName);
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"devicetoken"]){
        [currentInstallation removeObject:channelName forKey:@"channels"];
        [currentInstallation saveInBackground];
    }
}

+ (void)unsubscribeAllParseChannels{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"devicetoken"]) {
        NSArray *channels = [PFInstallation currentInstallation].channels;
        NSLog(@"PARSE CHANNEL ARE = %@",channels);
        for (int i = 0; i < [channels count]; i++) {
            NSLog(@"PARSE CHANNEL IS = %@",[channels objectAtIndex:i]);
            [currentInstallation removeObject:[channels objectAtIndex:i] forKey:@"channels"];
            [currentInstallation saveInBackground];
        }
    }
}

@end
