//
//  HttpWrapper.m
//  MyTime
//
//  Created by Chintan on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HttpWrapper.h"
#import "ASIFormDataRequest.h"
#import "inscriptsAppDelegate.h"
#import "ASIDownloadCache.h"
//#import "NSObject+SBJSON.h"


@implementation HttpWrapper

inscriptsAppDelegate *appDelegate;

@synthesize requestMain;
@synthesize delegate;

-(id)init {
    self = [super init];
    if(self)
    {
        appDelegate = [inscriptsAppDelegate sharedAppDelegate];
    }
    return self;
}


-(void) requestWithMethod:(NSString*)method url:(NSString*)strUrl param:(NSMutableDictionary*)dictParam
{
    NSLog(@"HttpWrapper method:%@ >> %@ ", method, strUrl);

    [ASIFormDataRequest clearSession];

    if(requestMain)
    {
        [requestMain release];
        requestMain = nil;
    }

    NSURL *url = [NSURL URLWithString:strUrl];
    requestMain = [ASIFormDataRequest requestWithURL:url];
    [requestMain setTimeOutSeconds:3000];
    [requestMain setPostFormat:ASIMultipartFormDataPostFormat];
    [requestMain setRequestMethod:method];
    [requestMain setUseCookiePersistence:NO];
    [requestMain setUseSessionPersistence:NO];

    [requestMain setShouldAttemptPersistentConnection:NO];

    
    if(dictParam != nil)
    {
        NSArray *allKey = [dictParam allKeys];
        for(int i=0; i<[allKey count]; i++)
        {
            NSString *key = [allKey objectAtIndex:i];
            NSString *value =[dictParam valueForKey:key];
            
            [requestMain setPostValue:value forKey:key];
            if (![key isEqualToString:@"sessionToken"]) {
            }
        }
    }
    
    [requestMain setDelegate:self];
    [requestMain startAsynchronous];
}

-(void) requestWithMethod:(NSString*)method url:(NSString*)strUrl param:(NSMutableDictionary*)dictParam arrFBFrnds : (NSMutableArray *)arrFrnd;
{
    
    NSLog(@"HttpWrapper method:%@ >> %@ ", method, strUrl);
    
    [ASIFormDataRequest clearSession];
    
    if(requestMain)
    {
        [requestMain release];
        requestMain = nil;
    }
    
    NSURL *url = [NSURL URLWithString:strUrl];
    requestMain = [ASIFormDataRequest requestWithURL:url];
    [requestMain setTimeOutSeconds:3000];
    [requestMain setPostFormat:ASIMultipartFormDataPostFormat];
    [requestMain setRequestMethod:method];
    [requestMain setUseCookiePersistence:NO];
    [requestMain setUseSessionPersistence:NO];
    
    [requestMain setShouldAttemptPersistentConnection:NO];
    
    
    if(dictParam != nil)
    {
        NSArray *allKey = [dictParam allKeys];
        for(int i=0; i<[allKey count]; i++)
        {
            NSString *key = [allKey objectAtIndex:i];
            NSString *value =[dictParam valueForKey:key];
            if (![key isEqualToString:@"sessionToken"]) {
                [requestMain setPostValue:value forKey:key];
            }

//            [requestMain setPostValue:value forKey:key];
        }
    }
    for (int i = 0; i<[arrFrnd count]; i++)
    {
        NSDictionary *dics1 = [arrFrnd objectAtIndex:i];
        [requestMain setPostValue:[dics1 valueForKey:@"id"] forKey:[NSString stringWithFormat:@"arrFrnd[%d][id]",i]];
        [requestMain setPostValue:[dics1 valueForKey:@"username"] forKey:[NSString stringWithFormat:@"arrFrnd[%d][username]",i]];
    }
    [requestMain setDelegate:self];
    [requestMain startAsynchronous];
}

-(void) requestWithImageUrl:(NSString*)strUrl toFolder:(NSString*)folderName {
    
    NSLog(@"HttpWrapper requestWithImageUrl:%@ >> %@", strUrl, folderName);
    
    //isImage = TRUE;
    
    NSURL *url = [NSURL URLWithString:strUrl];

    NSString *filePath = [[appDelegate applicationCacheDirectory] stringByAppendingPathComponent:folderName];
    filePath = [filePath stringByAppendingPathComponent:[url lastPathComponent]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath] == YES)
    {
        if([delegate respondsToSelector:@selector(fetchImageSuccess:)])
            [delegate performSelector:@selector(fetchImageSuccess:) withObject:filePath];
        return;
    }
    
    requestMain = [ASIHTTPRequest requestWithURL:url];
    [requestMain setDidFinishSelector:@selector(requestFinishedImage:)];
    [requestMain setDidFailSelector:@selector(requestFinishedImage:)];
    [requestMain setDownloadDestinationPath:filePath];
    [requestMain setShouldContinueWhenAppEntersBackground:YES];
    [requestMain setDelegate:self];
    [requestMain startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    NSString *responseString = [request responseString];
    NSLog(@"HttpWrapper > requestFinished > %@",responseString);
    
    NSString *jsonString = [[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding];
    
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    dics = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    if (delegate != nil) {
        if([delegate respondsToSelector:@selector(fetchDataSuccess:)])
        {
            [delegate performSelector:@selector(fetchDataSuccess:) withObject:dics];
        }
        
        if([delegate respondsToSelector:@selector(HttpWrapper:fetchDataSuccess:)])
        {
            [delegate HttpWrapper:self fetchDataSuccess:dics];
        }
        [jsonString release];
        requestMain = nil;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"HttpWrapper > requestFailed > error: %@",error);
    
    requestMain = nil;
    
    if (delegate == nil)
        return;
    
    if([delegate respondsToSelector:@selector(fetchDataFail:)])
        [delegate performSelector:@selector(fetchDataFail:) withObject:error];


    if([delegate respondsToSelector:@selector(HttpWrapper:fetchDataFail:)])
        [delegate HttpWrapper:self fetchDataFail:error];
}

- (void)requestFinishedImage:(ASIHTTPRequest *)request
{
    
    NSLog(@"HttpWrapper > requestFinishedImage > %@",[request downloadDestinationPath]);
    //NSData *responseData = [request responseData];
    if([delegate respondsToSelector:@selector(fetchImageSuccess:)])
        [delegate performSelector:@selector(fetchImageSuccess:) withObject:[request downloadDestinationPath]];
    
    requestMain = nil;
}

- (void)requestFailedImage:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"HttpWrapper > requestFailedImage > error: %@",error);
    
    requestMain = nil;
    
    if (delegate == nil)
        return;
    if([delegate respondsToSelector:@selector(fetchImageFail:)])
        [delegate performSelector:@selector(fetchImageFail:) withObject:error];
}

-(void) cancelRequest
{
    //if([requestMain isExecuting])
   // {
        requestMain.delegate = nil;
        [requestMain cancel];
        [requestMain clearDelegatesAndCancel];
   // }
}
@end
