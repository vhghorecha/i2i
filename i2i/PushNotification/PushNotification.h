//
//  PushNotification.h
//  CometChat
//
//  Created by Inscripts on 28/05/14.
//  Copyright (c) 2014 Inscripts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PushNotification : NSObject

+(void)registerParse;
+(void)registerDeviceToken:(NSData *)deviceToken;
+(void)subscribeToParseChannel:(NSString *)channelName;
+(void)subscribeAllParseChannel;
+(void)unsubscribeParseChannel:(NSString *)channelName;
+(void)unsubscribeAllParseChannels;

@end
