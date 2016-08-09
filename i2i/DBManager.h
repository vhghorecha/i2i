//
//  DBManager.h
//  SDKTestApp
//
//  Created by Inscripts on 22/01/16.
//  Copyright © 2016 inscripts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject

+ (DBManager *)getSharedInstance;
- (void)insertBuddyMessages:(NSDictionary *)messageData;
- (void)getMessages:(NSString *)message_id ofUsers:(NSMutableArray *)userArray updateFlag:(int)flag;
- (void)insertChatRoomMessages:(NSMutableArray *)messagesArray forChatRoom:(NSString *)roomID;
- (void)getChatRoomMessagesForChatRoom:(NSString *)roomID updateFlag:(int)flag;
- (void)truncateDatabseTables;
- (void)updateDeliveryReadMsg:(NSString *)msgID readFlag:(NSString *)readFlag userid:(NSString *)userid;
@end
