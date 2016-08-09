//
//  NativeKeys.m
//  SDKTestApp
//
//  Created by Inscripts on 30/09/14.
//  Copyright (c) 2014 inscripts. All rights reserved.
//

#import "NativeKeys.h"

@implementation NativeKeys


+ (void)getLogOType:(NSString *)type ForMessage:(NSString *)logMessage {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *_formatter = [[NSDateFormatter alloc] init];
    [_formatter setLocale:[NSLocale currentLocale]];
    _formatter.dateStyle = NSDateFormatterNoStyle;
    _formatter.timeStyle = kCFDateFormatterShortStyle;
    _formatter.doesRelativeDateFormatting = YES;
    NSString *timeString = [_formatter stringFromDate:date];
    
    [array addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:LOG_LIST]];
    [array addObject:[NSString stringWithFormat:@"(%@): %@ %@",timeString,type,logMessage]];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:LOG_LIST];
    
}

@end
