//
//  AsyncImage.h
//  Okoboji
//
//  Created by Ritesh on 28/08/14.
//  Copyright (c) 2014 LI018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "inscriptsAppDelegate.h"

@protocol AsyncImageDelegate<NSObject>

@optional

-(void) onAsyncTouch:(id)asyncImg;
-(void) FetchImageSuccess:(id)asyncImg;
-(void) FetchImageFail:(id)asyncImg;

@end

@interface AsyncImage : UIImageView<NSURLConnectionDataDelegate,NSURLConnectionDelegate>
{
    NSURLConnection* connection;
	NSMutableData* data;
	UIActivityIndicatorView *scrollingWheel;
    NSString *imgName;
    NSString *imgName2;
    NSString *strFolderName;
}

@property (nonatomic, strong) id<AsyncImageDelegate> delegate;
@property (nonatomic, strong) UIActivityIndicatorView *scrollingWheel;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property SEL onAsyncTouchSelector;

//- (void)loadImageFromExistingImage:(NSString*)stringUrl Folder:(NSString *)FolderName;
//-(void)loadImageFromStringforUserimg:(NSString*)url;
-(void)loadImageFromString:(NSString*)url;

-(void)cancelConnection;

-(id)initWithCoder:(NSCoder *)aDecoder;
-(id)initWithFrame:(CGRect)frame;
-(void)addGestureRecognizer;
@end