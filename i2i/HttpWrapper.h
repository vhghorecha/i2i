//
//  HttpWrapper.h
//  MyTime
//
//  Created by Chintan on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@class ASIFormDataRequest,HttpWrapper;

@protocol HttpWrapperDelegate

@optional

- (void) HttpWrapper:(HttpWrapper *)wrapper fetchDataSuccess:(NSMutableDictionary *)dicsResponse;
- (void) HttpWrapper:(HttpWrapper *)wrapper fetchDataFail:(NSError *)error;

- (void) fetchImageSuccess:(NSString *)response;
- (void) fetchImageFail:(NSError *)error;
- (void) fetchDataSuccess:(NSString *)response;
- (void) fetchDataFail:(NSError *)error;

- (void) HttpWrapper:(HttpWrapper *)wrapper fetchsuccesswithVideoData:(NSData *)videoData;
- (void) HttpWrapper:(HttpWrapper *)wrapper fetchsuccesswithVideoUrl:(NSString *)videoUrlString;


@end

@interface HttpWrapper : NSObject {
    
    ASIFormDataRequest *requestMain;
    
    NSMutableDictionary *dics;

    NSObject<HttpWrapperDelegate> *delegate;
    //BOOL isImage;
}

@property (nonatomic, assign) ASIFormDataRequest *requestMain;
@property (nonatomic, assign) NSObject<HttpWrapperDelegate> *delegate;

-(void) requestWithMethod:(NSString*)method url:(NSString*)strUrl param:(NSMutableDictionary*)dictParam;
-(void) requestWithMethod:(NSString*)method url:(NSString*)strUrl param:(NSMutableDictionary*)dictParam arrFBFrnds : (NSMutableArray *)arrFrnd;
-(void) requestWithImageUrl:(NSString*)strUrl toFolder:(NSString*)folderName;
-(void) cancelRequest;

@end
