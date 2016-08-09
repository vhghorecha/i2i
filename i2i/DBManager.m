//
//  DBManager.m
//  SDKTestApp
//
//  Created by Inscripts on 22/01/16.
//  Copyright © 2016 inscripts. All rights reserved.
//

#import "DBManager.h"
#import "NativeKeys.h"

#define FMDBQuickCheck(SomeBool) { if (!(SomeBool)) { NSLog(@"Failure on line %d", __LINE__); abort(); } }

static sqlite3 *cometchatDB = nil;
static sqlite3_stmt *statement = nil;
static DBManager *sharedInstance = nil;
NSObject<OS_dispatch_queue> *queue_database_operations;

@implementation DBManager{
    
    NSString *databasePath;
    BOOL buddyMsgSuccessFlag;
    
}

/* Create single instance of DBManager */
+ (DBManager *)getSharedInstance {
    
    if(sharedInstance == nil){
        
        sharedInstance = [[DBManager allocWithZone:NULL] init];
        queue_database_operations = dispatch_queue_create("com.inscripts.cometchatapp.queue.databaseoperation", NULL);
        
        [sharedInstance createDB];
    }
    return sharedInstance;
}

- (void)createDB {
    
    NSString *directoryPath;
    NSArray *directoryArray;
    
    directoryArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    directoryPath = directoryArray[0];
    
    dispatch_async(queue_database_operations, ^{
        
        BOOL success = NO;
        databasePath = [[NSString alloc] initWithString:[directoryPath stringByAppendingPathComponent:@"cometchat_app.db"]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        const char *charPath = [databasePath UTF8String];
        
        if([fileManager fileExistsAtPath:databasePath] == NO) {
            
            if(sqlite3_open(charPath, &cometchatDB) == SQLITE_OK){
                
                NSLog(@"DBMANAGER : CometChat App Database created! %s",charPath);
                success = YES;
                
            } else {
                
                success = NO;
                NSLog(@"DBMANAGER : Failed to create database -> %s",sqlite3_errmsg(cometchatDB));
                
            }
            
        } else {
            success = YES;
            sqlite3_open(charPath, &cometchatDB);
            
        }
        
        NSLog(@"DBMANAGER : DATABASE PATH -> %@",databasePath);
        
        if (success) {
            
            /* Creating buddy_messages table */
            const char *sql_stmt ="create table if not exists buddy_messages (id integer primary key autoincrement, message_id integer not null unique, sender integer ,receiver integer , message text, timestamp long, messageTypeFlag integer, messageread integer)";
            
            if(sqlite3_exec(cometchatDB, sql_stmt, NULL, NULL, NULL) != SQLITE_OK){
                
                NSLog(@"DBMANAGER : Failed to create buddy_messages table -> %s",sqlite3_errmsg(cometchatDB));
                sqlite3_close(cometchatDB);
                
            } else{
                NSLog(@"DBMANAGER : buddy_messages table created");
            }
            
            /* Creating chatroom_messages table */
            sql_stmt ="create table if not exists chatroom_messages (id integer primary key autoincrement, chatroom_id text, sender_name text, sender_id integer, message_id long not null unique, message text, timestamp long, messageTypeFlag integer, message_color text)";
            
            if(sqlite3_exec(cometchatDB, sql_stmt, NULL, NULL, NULL) != SQLITE_OK){
                
                NSLog(@"DBMANAGER : Failed to create chatroom_messages table -> %s",sqlite3_errmsg(cometchatDB));
                sqlite3_close(cometchatDB);
                
            } else {
                NSLog(@"DBMANAGER : chatroom_messages table created");
            }
            
            sql_stmt = "select message_status from buddy_messages";
            
            if(sqlite3_exec(cometchatDB, sql_stmt, NULL, NULL, NULL) != SQLITE_OK){
                
                sql_stmt ="ALTER TABLE buddy_messages ADD message_status text DEFAULT 1";
                
                if(sqlite3_exec(cometchatDB, sql_stmt, NULL, NULL, NULL) != SQLITE_OK) {
                    
                    NSLog(@"DBMANAGER : Failed to alter buddy_messages table -> %s",sqlite3_errmsg(cometchatDB));
                    
                } else {
                    NSLog(@"DBMANAGER : buddy_messages table altered with query -> %s",sql_stmt);
                }
            }
            
            sql_stmt = "select message_status from chatroom_messages";
            
            if(sqlite3_exec(cometchatDB, sql_stmt, NULL, NULL, NULL) != SQLITE_OK){
                
                sql_stmt ="ALTER TABLE chatroom_messages ADD message_status text";
                
                if(sqlite3_exec(cometchatDB, sql_stmt, NULL, NULL, NULL) != SQLITE_OK) {
                    
                    NSLog(@"DBMANAGER : Failed to alter chatroom_messages table -> %s",sqlite3_errmsg(cometchatDB));
                    
                } else {
                    NSLog(@"DBMANAGER : chatroom_messages table altered with query -> %s",sql_stmt);
                }
            }
        }
    });
}

- (void)insertBuddyMessages:(NSDictionary *)messageData {
    
    NSDictionary *messages = [messageData objectForKey:@"messages"];
    
    /* Sort message keys according to timestamp */
    //    __block NSArray *keys = [messages allKeys];
    //    // NSLog(@"insert dictionary = %@",messages);
    //
    //    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"self"
    //                                                                 ascending:YES];
    //    keys = [keys sortedArrayUsingDescriptors:@[descriptor]];
    //    descriptor = nil;
    //
    //    /* Reset buddyMsgSuccessFlag */
    //    buddyMsgSuccessFlag = NO;
    //
    //    /* Process each message in sorted dictionary */
    dispatch_async(queue_database_operations, ^{
        //
        //        for(id message in keys){
        
        //NSDictionary *messageDictionary = messages objectForKey:message];
        
        /* If buddy information is not present in user defaults buddy list then get buddyInfo from server */
        
        [self processBuddyMessage:@{@"message":messages}];
        
        // messageDictionary = nil;
        //        }
        //        keys = nil;
        
        /* If any new message then notify user */
        if (buddyMsgSuccessFlag) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.cometchat.oneonechatmessagenotifier" object:nil ];
            });
        }
    });
}

/* Process each Buddy message */
- (void)processBuddyMessage:(NSDictionary *)messageData {
    
    //NSLog(@"PROCESSING in DBManager %@",messageData);
    NSDictionary *messageDictionary = [messageData objectForKey:@"message"];
    
    /* Retrieve all fields from message */
    NSString *message = [messageDictionary objectForKey:@"message"];
    //NSString *thumbPicPath = [messageDictionary objectForKey:@"thumbPicPath"];
    NSNumber *message_id = [messageDictionary objectForKey:@"id"];
    NSString *timestamp;
    NSNumber *isSelf = @([[messageDictionary objectForKey:@"self"] intValue]);
    NSNumber *sender;
    NSNumber *receiver;
    NSString *messageStatus;
    NSNumber *msgreadstatus = @-1;
    
    /* Set flag for various message type and whether to save message in database or not */
    
    int typeOfMsg = 0;
    BOOL success = NO;
    BOOL normalMsgFlag = NO;
    NSNumber *messageTypeFlag = @0;
    
    if ([[NSString stringWithFormat:@"%@",[messageDictionary objectForKey:@"sent"]] length] > 10) {
        timestamp = [NSString stringWithFormat:@"%@",[messageDictionary objectForKey:@"sent"]];
    } else {
        timestamp = [NSString stringWithFormat:@"%@000",[messageDictionary objectForKey:@"sent"]];
    }
    
    if([messageDictionary objectForKey:@"message_type"]){
        
        messageTypeFlag = @([[messageDictionary objectForKey:@"message_type"] intValue]);
        
    }
    
    //NSNumber *downloadStatusFlag;
    
    timestamp = [NSString stringWithFormat:@"%lld",(long long)[timestamp longLongValue]];
    
    /* If saveMsgFlag is YES then save message to database and notify user accordingly -> This has been removed */
    
    /* Check for self message */
    if ([isSelf isEqual:@0]) {
        
        sender = [messageDictionary objectForKey:@"from"];
        receiver = [[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER];
        messageStatus = @"1";
    }
    else if ([isSelf isEqual:@1]){
        
        sender = [[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER];
        receiver = [messageDictionary objectForKey:@"from"];
        messageStatus = @"0";
    }
    
    const char *charPath = [databasePath UTF8String];
    const char *error;
    if(sqlite3_open(charPath, &cometchatDB) == SQLITE_OK)
    {
        //NSLog(@"MESSAGE 1 %@",message);
        message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"U+0022"];
        
        NSString *insertQuery = [NSString stringWithFormat:@"insert into buddy_messages (message_id ,sender,receiver,message,timestamp,messageTypeFlag,message_status,messageread)values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",message_id,sender,receiver,message,timestamp,messageTypeFlag,messageStatus,msgreadstatus];
        const char *query = [insertQuery UTF8String];
        
        NSLog(@"insert query = %@",insertQuery);
        
        sqlite3_prepare_v2(cometchatDB, query, -1, &statement,&error);
        NSInteger result = sqlite3_step(statement);
        if (result == SQLITE_DONE) {
            success = YES;
            
            NSLog(@"inserted %i", success);
        }
        else if(result == SQLITE_BUSY){
            NSLog(@"message not inserted db busy = %s\n", sqlite3_errmsg(cometchatDB));
            success = NO;
        } else {
            NSLog(@"message not inserted error = %s\n", sqlite3_errmsg(cometchatDB));
            success = NO;
        }
        sqlite3_reset(statement);
        
    }
    
    if (success) {
        buddyMsgSuccessFlag = YES;
    }
    
}

- (void)updateDeliveryReadMsg:(NSString *)msgID readFlag:(NSString *)readFlag userid:(NSString *)userid{
    
    dispatch_async(queue_database_operations, ^{
        
        const char *charPath = [databasePath UTF8String];
        BOOL success = NO;
        const char *error;
        
        if(sqlite3_open(charPath, &cometchatDB) == SQLITE_OK)
        {
            //NSLog(@"MESSAGE 1 %@",message);
            
            NSString *selfid = [[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER];
            
            NSString *updateQuery;
            
            if ([readFlag isEqualToString:@"-1"]) {
                updateQuery = [NSString stringWithFormat:@"UPDATE buddy_messages SET messageread = \"%@\" WHERE (message_id=\"%@\") AND  (sender=\"%@\" AND receiver=\"%@\")",@"-1",msgID,selfid,userid];
            } else if([readFlag isEqualToString:@"0"]){
                updateQuery = [NSString stringWithFormat:@"UPDATE buddy_messages SET messageread = \"%@\" WHERE (message_id=\"%@\") AND  (sender=\"%@\" AND receiver=\"%@\") AND messageread = \"-1\"",@"0",msgID,selfid,userid];
            } else if ([readFlag isEqualToString:@"1"]) {
                updateQuery = [NSString stringWithFormat:@"UPDATE buddy_messages SET messageread = \"%@\" WHERE (message_id<=\"%@\") AND  (sender=\"%@\" AND receiver=\"%@\") AND messageread <> \"1\"",@"1",msgID,selfid,userid];
            } else if ([readFlag isEqualToString:@"2"]) {
                
                updateQuery = [NSString stringWithFormat:@"UPDATE buddy_messages SET messageread = \"%@\" WHERE (sender=\"%@\" AND receiver=\"%@\") AND messageread <> 1",@"1",selfid,userid];
                
            }
            const char *query = [updateQuery UTF8String];
            
            NSLog(@"update query = %@",updateQuery);
            
            sqlite3_prepare_v2(cometchatDB, query, -1, &statement,&error);
            NSInteger result = sqlite3_step(statement);
            if (result == SQLITE_DONE) {
                success = YES;
                
                NSLog(@"update %i", success);
            }
            else if(result == SQLITE_BUSY){
                NSLog(@"message not update db busy = %s\n", sqlite3_errmsg(cometchatDB));
                success = NO;
            } else {
                NSLog(@"message not update error = %s\n", sqlite3_errmsg(cometchatDB));
                success = NO;
            }
            sqlite3_reset(statement);
            
        }
    });
}

/* Get one-on-one chat messages */
- (void)getMessages:(NSString *)message_id ofUsers:(NSMutableArray *)userArray updateFlag:(int)flag {
    
    dispatch_async(queue_database_operations, ^{
        
        NSString *user1 = [userArray objectAtIndex:0];
        NSString *user2 = [userArray objectAtIndex:1];
        NSMutableArray *allMessages = [[NSMutableArray alloc] init];
        NSNumber *isSelf;
        NSString *msgReadStatus;
        NSString *from;
        const char *charPath = [databasePath UTF8String];
        const char *error;
        if(sqlite3_open(charPath, &cometchatDB) == SQLITE_OK)
        {
            NSString *selectQuery = [NSString stringWithFormat:
                                     @"SELECT message_id, sender, receiver, message ,timestamp, messageTypeFlag,message_status,messageread FROM buddy_messages WHERE (message_id>\"%@\") AND  ((sender=\"%@\" AND receiver=\"%@\") OR (sender=\"%@\" AND receiver=\"%@\")) ORDER BY id DESC LIMIT %@ ",message_id,user1,user2,user2,user1,@"30"];
            // NSLog(@"select query = %@",selectQuery);
            const char *query = [selectQuery UTF8String];
            if(sqlite3_prepare_v2(cometchatDB, query, -1, &statement, &error) == SQLITE_OK)
            {
                while(sqlite3_step(statement) == SQLITE_ROW)
                {
                    //NSNumber *message_id = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)] ;
                    
                    
                    NSString *message_id = [[NSString alloc]initWithUTF8String:
                                            (const char *) sqlite3_column_text(statement, 0)];
                    
                    NSString *sender = [[NSString alloc]initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 1)];
                    NSString *receiver = [[NSString alloc]initWithUTF8String:
                                          (const char *) sqlite3_column_text(statement, 2)];
                    
                    NSString *message = [[NSString alloc]initWithUTF8String:
                                         (const char *) sqlite3_column_text(statement, 3)];
                    message = [message stringByReplacingOccurrencesOfString:@"U+0022" withString:@"\""];
                    
                    
                    NSNumber *messageTypeFlag = [NSNumber numberWithInt:sqlite3_column_int(statement, 5)] ;
                    
                    //NSNumber *downloadStatusFlag = [NSNumber numberWithInt:sqlite3_column_int(statement, 6)] ;
                    
                    NSString *messageStatus;
                    
                    if ((char *) sqlite3_column_text(statement, 6))
                        
                        messageStatus = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 6)];
                    else
                        messageStatus = @"0";
                    
                    NSString *timestamp = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                    
                    if ([sender isEqualToString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGGED_IN_USER]]]) {
                        isSelf = @1;
                        from = receiver;
                    }
                    else{
                        isSelf = @0;
                        from = sender;
                    }
                    
                    msgReadStatus = [[NSString alloc]initWithUTF8String:
                                     (const char *) sqlite3_column_text(statement, 7)];
                    
                    NSDictionary *temp = [NSDictionary dictionaryWithObjectsAndKeys:from,@"from",message_id,@"id",message,@"message",@"1",@"old",isSelf,@"self",timestamp,@"sent",messageTypeFlag,MESSAGE_TYPE_KEY,messageStatus,@"messageStatus",msgReadStatus,@"readmsg",nil];
                    
                    [allMessages addObject:temp];
                    
                }
                sqlite3_reset(statement);
                
            } else{
                NSLog(@"GET MESSAGES ERROR = %s",sqlite3_errmsg(cometchatDB));
            }
        }
        NSMutableArray *reverseArrayOfMessages = [NSMutableArray arrayWithArray:[[allMessages reverseObjectEnumerator] allObjects]];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.cometchat.updatechatmessages" object:nil userInfo:@{@"TAG":[NSString stringWithFormat:@"%d",flag],@"data":reverseArrayOfMessages}];
            
        });
    });
}

/* Insert chatroom messages */
- (void)insertChatRoomMessages:(NSMutableArray *)messagesArray forChatRoom:(NSString *)roomID {
    
    dispatch_async(queue_database_operations, ^{
        
        BOOL success = NO;
        for (NSDictionary *message in messagesArray) {
            
            //NSLog(@"Chatroom message Dictionary %@ \n roomID = %@",message,roomID);
            const char *charPath = [databasePath UTF8String];
            
            if(sqlite3_open(charPath, &cometchatDB) == SQLITE_OK) {
                
                NSString *sender_name = [message objectForKey:FROM];
                NSString *sender_id = [message objectForKey:@"fromid"];
                NSString *message_id = [message objectForKey:@"id"];
                NSString *messageText = [message objectForKey:MESSAGE];
                //NSString *thumbPicPath = [message objectForKey:@"thumbPicPath"];
                NSString *timestamp;
                NSNumber *messageTypeFlag = @0;
                //NSNumber *downloadStatusFlag;
                NSString *messageColor;
                int typeOfMsg = 0;
                BOOL normalMsgFlag = NO;
                
                if ([[NSString stringWithFormat:@"%@",[message objectForKey:@"sent"]] length] > 10) {
                    
                    timestamp = [NSString stringWithFormat:@"%@",[message objectForKey:@"sent"]];
                    
                } else {
                    
                    timestamp = [NSString stringWithFormat:@"%@000",[message objectForKey:@"sent"]];
                    
                }
                
                if ([message objectForKey:MESSAGE_TYPE_KEY]) {
                    messageTypeFlag = @([[message objectForKey:MESSAGE_TYPE_KEY] intValue]);
                }
                
                /* If cometservice is On, then sender_name comes as the logged-in user's name. So change it to 'Me' for standardization */
                
                if ([sender_name isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"name"]]) {
                    
                    sender_name = @"Me" ;
                }
                
                /* When CC^CONTROL_ is sent as colored text, check for empty message after processing span tag*/
                if ([messageText isEqualToString:@""]) {
                    continue;
                }
                
                /* Replace occurance of br tag to next line character */
                messageText = [messageText stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
                
                /* Store filterd message in database */
                
                /* Store message in database */
                messageText = [messageText stringByReplacingOccurrencesOfString:@"\"" withString:@"U+0022"];
                NSString *insertQuery = [NSString stringWithFormat:@"insert into chatroom_messages (chatroom_id,sender_name ,sender_id, message_id, message,timestamp, messageTypeFlag,message_color ) values (\"%@\",\"%@\",\"%@\",\"%lld\",\"%@\",\"%@\",\"%@\",\"%@\")",roomID,sender_name,sender_id,[message_id longLongValue],messageText,timestamp,messageTypeFlag,messageColor];
                
                //NSLog(@"Chatroom insert query %@",insertQuery);
                
                const char *query = [insertQuery UTF8String];
                const char *err;
                sqlite3_prepare_v2(cometchatDB, query, -1, &statement, &err);
                if (sqlite3_step(statement) == SQLITE_DONE) {
                    success = YES;
                    //                    if (![[message objectForKey:@"deviceType"] isEqualToString:@"iOS"]) {
                    //
                    //                        success = YES;
                    //                        NSDictionary *messageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:sender_name,FROM,sender_id,FROM_ID,message_id,ID,messageText,MESSAGE,timestamp,MESSAGE_TIMESTAMP,messageTypeFlag,MESSAGE_TYPE_FLAG,downloadStatusFlag,@"downloadStatusFlag",nil];
                    //                        [tempMessageArray addObject:messageDictionary];
                    //
                    //                    } else {
                    //
                    //                        NSLog(@"device type ios");
                    //                        success = NO;
                    //                    }
                    
                    NSLog(@"chatroom inserted %i", success);
                    
                }
                else{
                    
                    NSLog(@"chatroom messages not inserted with err %s",sqlite3_errmsg(cometchatDB));
                }
                sqlite3_reset(statement);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            /* If any new message then notify user */
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.cometchat.chatroommessagenotifier" object:nil];
            }
        });
    });
}

/* Load Messages from local database for specified chatroom */
- (void)getChatRoomMessagesForChatRoom:(NSString *)roomID updateFlag:(int)flag {
    
    dispatch_async(queue_database_operations, ^{
        
        NSMutableArray *allMessages = [[NSMutableArray alloc] init];
        const char *charPath = [databasePath UTF8String];
        const char *error;
        if(sqlite3_open(charPath, &cometchatDB) == SQLITE_OK)
        {
            NSString *selectQuery = [NSString stringWithFormat: @"SELECT sender_name ,sender_id, message_id, message ,timestamp, messageTypeFlag,message_color,message_status FROM chatroom_messages WHERE (chatroom_id=\"%@\") ORDER by id DESC LIMIT %@",roomID,@"30"];
            //NSLog(@"GET CHATROOM MESSAGES QUERY %@",selectQuery);
            const char *query = [selectQuery UTF8String];
            if(sqlite3_prepare_v2(cometchatDB, query, -1, &statement, &error) == SQLITE_OK)
            {
                while(sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSString *sender_name = [[NSString alloc] initWithUTF8String:
                                             (const char *) sqlite3_column_text(statement, 0)];
                    NSString *sender_id = [[NSString alloc]initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 1)];
                    //NSNumber *message_id = [NSNumber numberWithInt:sqlite3_column_int(statement, 2)];
                    NSString *message_id = [[NSString alloc]initWithUTF8String:
                                            (const char *) sqlite3_column_text(statement, 2)];
                    NSString *message = [[NSString alloc]initWithUTF8String:
                                         (const char *) sqlite3_column_text(statement, 3)];
                    message = [message stringByReplacingOccurrencesOfString:@"U+0022" withString:@"\""];
                    
                    NSString *timestamp = [[NSString alloc]initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 4)];
                    NSNumber *messageTypeFlag = [NSNumber numberWithInt:sqlite3_column_int(statement, 5)] ;
                    //NSNumber *downloadStatusFlag = [NSNumber numberWithInt:sqlite3_column_int(statement, 6)] ;
                    NSString *message_color = [[NSString alloc]initWithUTF8String:
                                               (const char *) sqlite3_column_text(statement, 6)];
                    
                    NSString *messageStatus;
                    if ((char *) sqlite3_column_text(statement, 7))
                        
                        messageStatus = [[NSString alloc] initWithUTF8String:(char *) sqlite3_column_text(statement, 7)];
                    else
                        messageStatus = @"0";
                    
                    NSDictionary *messageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:sender_name,FROM,sender_id,@"fromid",message_id,@"id",message,MESSAGE,timestamp,@"sent",messageTypeFlag,MESSAGE_TYPE_KEY,message_color,@"messageColor",messageStatus,@"messageStatus",nil];
                    
                    /* Add message dictionary to all messages array */
                    [allMessages addObject:messageDictionary];
                }
                sqlite3_reset(statement);
                
            } else {
                NSLog(@"GET CHATROOM MESSAGES STEP3 NOT EXECUTED = %s",sqlite3_errmsg(cometchatDB));
            }
        }
        
        NSMutableArray* reverseArrayOfMessages = [NSMutableArray arrayWithArray:[[allMessages reverseObjectEnumerator] allObjects]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.inscripts.cometchat.updatechatroommessages" object:nil userInfo:@{@"TAG":[NSString stringWithFormat:@"%d",flag],@"data":reverseArrayOfMessages}];
        });
    });
}

/* Truncate All tables in database */
- (void)truncateDatabseTables {
    
    NSLog(@"truncate DB");
    dispatch_async(queue_database_operations, ^{
        
        const char *charPath = [databasePath UTF8String];
        const char *error;
        if(sqlite3_open(charPath, &cometchatDB) == SQLITE_OK)
        {
            /* Truncate buddy_messages table */
            NSString *deleteQuery = [NSString stringWithFormat:@"Delete from buddy_messages"];
            NSLog(@"delete query = %@",deleteQuery);
            const char *query = [deleteQuery UTF8String];
            if(sqlite3_prepare_v2(cometchatDB, query, -1, &statement, &error) == SQLITE_OK)
            {
                if(sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"buddy_messages delete query implemented");
                }
                else{
                    NSLog(@"buddy_messages delete query error -> %s",sqlite3_errmsg(cometchatDB));
                }
                sqlite3_reset(statement);
                
            }else{
                NSLog(@"buddy_messages delete query not excecuted");
            }
            
            /* Truncate chatroom_messages table */
            deleteQuery = [NSString stringWithFormat:@"Delete from chatroom_messages"];
            NSLog(@"delete query = %@",deleteQuery);
            query = [deleteQuery UTF8String];
            if(sqlite3_prepare_v2(cometchatDB, query, -1, &statement, &error) == SQLITE_OK)
            {
                if(sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"chatroom_messages delete query implemented");
                }
                else{
                    NSLog(@"chatroom_messages delete error -> %s",sqlite3_errmsg(cometchatDB));
                }
                sqlite3_reset(statement);
                
            }else{
                NSLog(@"chatroom_messages delete query not excecuted");
            }
            
        }
    });
}
@end
