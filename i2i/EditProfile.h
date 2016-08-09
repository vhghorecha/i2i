//
//  EditProfile.h
//  SDKTestApp
//
//  Created by Darshan on 29/07/16.
//  Copyright © 2016 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "HttpWrapper.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ImageCell.h"
#import "AsyncImage.h"
#import "inscriptsAppDelegate.h"

@interface EditProfile : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate,HttpWrapperDelegate , ImageCellDelegate>
{
    ASIHTTPRequest *request;
    ASIFormDataRequest *upRequest;
    ASIFormDataRequest *upImgRequest;
    
    HttpWrapper *httpGetFeed;
    HttpWrapper *httpDeleteImg;
    HttpWrapper *httpDeleteVid;
    BOOL upLoadVideo;
    
    float collectionWidth;
    
    float imageIndex;
    float videoIndex;
}

//UIView
@property (nonatomic , strong) IBOutlet UIView *viewUser;
@property (nonatomic , strong) IBOutlet UIView *viewStatues;

//UITextField
@property (nonatomic , strong) IBOutlet UITextField *txtUserName;
@property (nonatomic , strong) IBOutlet UITextField *txtStatus;

//UIImageView
@property (nonatomic , strong) IBOutlet AsyncImage *imgProfile;

@property (nonatomic , strong) IBOutlet UIButton *btnAddMedia;

@property (nonatomic , strong) UIImageView *imgProfilePic;

@property (nonatomic , strong) IBOutlet UICollectionView *objImageCollection;
@property (nonatomic , strong) IBOutlet UICollectionView *objVideoCollection;

@property (nonatomic , strong) NSMutableArray *arrImage;
@property (nonatomic , strong) NSMutableArray *arrVideo;


@end
