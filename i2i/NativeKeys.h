//
//  NativeKeys.h
//  SDKTestApp
//
//  Created by Inscripts on 30/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NativeKeys : NSObject

#define BUDDY_NAME  @"n"
#define CHATROOM_NAME @"name"
#define ID @"id"
#define FROM @"from"
#define OLD @"old"
#define SELF @"self"
#define SENT @"sent"
#define MESSAGE @"message"
#define SENT_MESSAGE @"m"
#define TYPE @"type"
#define MESSAGE_TYPE_KEY @"message_type"
#define S @"s"
#define M @"m"
#define CHATROOM_PASSWORD @"i"
#define LOGGED_IN_USER @"loggedinuser"
#define CURRENT_BUDDY_ID @"current_buddy"
#define CURRENT_CHATROOM_ID @"current_chatrom_id"
#define BUDDY_LIST  @"BUDDY_LIST"
#define RESPONSE @"response"
#define LOG_LIST  @"LOG_LIST"

#define LOG_TYPE_ONE_ON_ON  @"OneOnOne"
#define LOG_TYPE_CHATROOM  @"Chatroom"
#define LOG_TYPE_AVCHAT @"AVChat"
#define LOG_TYPE_AV_GROUP_CONFERENCE @"Group Conference"

#define MESSAGE_TYPE_STANDARD @"10"
#define MESSAGE_TYPE_IMAGE @"12"
#define MESSAGE_TYPE_VIDEO @"14"
#define MESSAGE_TYPE_AUDIO @"17"
#define MESSAGE_TYPE_FILE @"18"
#define MESSAGE_TYPE_STICKER @"20"

#define ONLINE_STATUS_AVAILABLE @"available"
#define ONLINE_STATUS_BUSY @"busy"
#define ONLINE_STATUS_AWAY @"away"
#define ONLINE_STATUS_INVISIBLE @"invisible"
#define ONLINE_STATUS_OFFLINE @"offline"

#define LOGIN_DETAILS @"loginDetails"
#define LOGIN_TYPE_USERID @1
#define LOGIN_TYPE_USERNAME @2
#define LOGIN_TYPE_GUEST @3

+(void) getLogOType:(NSString *)type ForMessage:(NSString *)logMessage;

@end
