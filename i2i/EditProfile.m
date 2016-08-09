//
//  EditProfile.m
//  SDKTestApp
//
//  Created by Darshan on 29/07/16.
//  Copyright © 2016 inscripts. All rights reserved.
//

#import "EditProfile.h"
#import "inscriptsAppDelegate.h"
#import "ImageCell.h"
#import "NativeKeys.h"
#import <MobileCoreServices/UTCoreTypes.h>

#define profile_Url [NSString stringWithFormat:@"%@",API_URL]

@interface EditProfile ()

@end

@implementation EditProfile

@synthesize imgProfile;

//UIView
@synthesize viewUser;
@synthesize viewStatues;

//UITextField
@synthesize txtUserName;
@synthesize txtStatus;

@synthesize btnAddMedia;
@synthesize imgProfilePic;

@synthesize objImageCollection;
@synthesize objVideoCollection;

@synthesize arrImage;
@synthesize arrVideo;

inscriptsAppDelegate *appDelegates;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegates = [inscriptsAppDelegate sharedAppDelegate];
    
    [objImageCollection registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [objVideoCollection registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    objImageCollection.delegate = self;
    objImageCollection.dataSource = self;
    objImageCollection.backgroundColor = [UIColor clearColor];

    objVideoCollection.delegate = self;
    objVideoCollection.dataSource = self;
    objVideoCollection.backgroundColor = [UIColor clearColor];
    
    imgProfile.layer.cornerRadius = 50.0f;
    imgProfile.layer.masksToBounds = YES;
    
    viewUser.layer.cornerRadius = 4.0f;
    viewStatues.layer.cornerRadius = 4.0f;
    
    txtUserName.userInteractionEnabled = NO;
    txtStatus.userInteractionEnabled = NO;

    upLoadVideo = false;
        
//    [objImageCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [objImageCollection registerClass:[ImageCell class] forCellWithReuseIdentifier:@"Cell"];
    
    [objVideoCollection registerClass:[ImageCell class] forCellWithReuseIdentifier:@"Cell"];
    
    imageIndex = 0;
    videoIndex = 0;
    
    NSString *userID =[[NSUserDefaults standardUserDefaults]objectForKey:LOGGED_IN_USER];
    
    [self checkAPI:userID];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
}
-(void)checkAPI:(NSString *)usrId
{
    /*
     User Profile
     action=userprofile
     userid=<current_user_id>
     api-key=c00eaa64e2ac3eabb7ddbdb33ca9b681
     */
    
    if(httpGetFeed)
    {
        [httpGetFeed cancelRequest];
        httpGetFeed.delegate = nil;
        httpGetFeed = nil;
    }
    httpGetFeed = [[HttpWrapper alloc] init];
    httpGetFeed.delegate=self;
    
    [appDelegates showLoadingView];
    NSLog(@"LOGIN_DETAILS %@",[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_DETAILS]);
    NSMutableDictionary *dics = [[NSMutableDictionary alloc]init];
    [dics setValue:@"userprofile" forKey:@"action"];
    [dics setValue:usrId forKey:@"userid"];
    [dics setValue:USER_KEYS forKey:@"api-key"];
    NSLog(@"%@", dics);
    [httpGetFeed requestWithMethod:@"POST" url:API_URL param:dics];
}
- (void) HttpWrapper:(HttpWrapper *)wrapper fetchDataSuccess:(NSMutableDictionary *)dicsResponse
{
    if(wrapper == httpGetFeed){
        NSLog(@"DICT %@", dicsResponse);
        if([dicsResponse objectForKey:@"success"]){
            
            NSDictionary *dictUsr =[[dicsResponse objectForKey:@"success"] objectForKey:@"user"];
            NSArray *image =[dictUsr objectForKey:@"images"];
            if(image  != nil){
                
                arrImage =[[NSMutableArray alloc]initWithArray:image];
            }
            NSArray *vidos =[dictUsr objectForKey:@"videos"];
            if(vidos != nil){
                arrVideo =[[NSMutableArray alloc]initWithArray:vidos];
            }
            
            [objVideoCollection reloadData];
            [objImageCollection reloadData];
            
            txtUserName.text = [dictUsr objectForKey:@"username"];
            NSString *imgAvt =[dictUsr objectForKey:@"avatar"];
            if(imgAvt != nil && imgAvt.length > 0){
                
                if(![imgAvt hasPrefix:@"www."]) {
//                    [imgProfile loadImageWithURl:[NSString stringWithFormat:@"www.%@",imgAvt] andPlaceHolderImage:nil];
                }else{
                    
                }
            }
            
        }else{
            [SHARED_APPDELEGATE showAlertWithTitle:@"" andMessage:@"Fail to get user profile." delegate:self];
            
        }
    }
    else if(wrapper == httpDeleteImg){
        
        NSLog(@"RESP %@", dicsResponse);
        if([dicsResponse objectForKey:@"success"]){
            
            NSDictionary *dic =[dicsResponse objectForKey:@"success"];
            [SHARED_APPDELEGATE showAlertWithTitle:@"" andMessage:[dic objectForKey:@"message"] delegate:self];
            
            NSString *userID =[[NSUserDefaults standardUserDefaults]objectForKey:LOGGED_IN_USER];
            [self checkAPI:userID];
        }
    }
    
    else if(wrapper == httpDeleteVid){
        
        NSLog(@"RESP %@", dicsResponse);
        if([dicsResponse objectForKey:@"success"]){
            
            NSDictionary *dic =[dicsResponse objectForKey:@"success"];
            [SHARED_APPDELEGATE showAlertWithTitle:@"" andMessage:[dic objectForKey:@"message"] delegate:self];
            
            NSString *userID =[[NSUserDefaults standardUserDefaults]objectForKey:LOGGED_IN_USER];
            [self checkAPI:userID];
        }
    }
    
    [appDelegates hideLoadingView];
}

#pragma mark - Reachability Notification Methods

- (void) HttpWrapper:(HttpWrapper *)wrapper fetchDataFail:(NSError *)error
{
    NSLog(@"ERROR %@", error);
    [appDelegates hideLoadingView];
}

#pragma mark -
#pragma mark - TextField FirstResponder

-(void)hideallKeyBoard
{
    if([txtUserName isFirstResponder]){
        [txtUserName resignFirstResponder];
    }
    if([txtStatus isFirstResponder]){
        [txtStatus resignFirstResponder];
    }
}

#pragma mark -
#pragma mark - TEXT FILED DELEGATE

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag;
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag+1];
    
    if (nextResponder)
    {
        [nextResponder becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint point;
    
    if (textField == txtUserName) {
        point = CGPointMake(0, 0);
    }else if (textField == txtStatus){
        point = CGPointMake(0, 0);
    }
}

- (IBAction)onClickEditProfileBtn:(id)sender {
 
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Select Image And Video:"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhotoAction = [UIAlertAction
                                      actionWithTitle:@"Select Photo In Gallery"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [self TakePhotoIntoGallary];
                                          [alertController dismissViewControllerAnimated:YES completion:nil];
                                          
                                      }];
    
    UIAlertAction *galleryPhotoAction = [UIAlertAction
                                         actionWithTitle:@"Select Video In Gallery"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [self TakeVideoInGallary];
                                             [alertController dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
    
    
    UIAlertAction *cancelAction  = [UIAlertAction
                                    actionWithTitle:@"Cancel"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alertController dismissViewControllerAnimated:YES completion:nil];
                                        
                                    }];
    
    [alertController addAction:takePhotoAction];
    [alertController addAction:galleryPhotoAction];
    [alertController addAction:cancelAction];
    
    alertController.popoverPresentationController.sourceView = self.view;
    alertController.popoverPresentationController.sourceRect = CGRectMake((btnAddMedia.frame.origin.x + btnAddMedia.frame.size.width), (btnAddMedia.frame.origin.y + btnAddMedia.frame.size.height) + 35, 1.0, 1.0);
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)TakePhotoIntoGallary
{
    NSLog(@"TakePhotoIntoGallary");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
-(void)TakeVideoInGallary
{
    upLoadVideo = true;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    
    [imagePicker setMediaTypes:[[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil]];
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (upLoadVideo == true) {
        
        NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
        
        if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            if ([mediaType isEqualToString:@"public.movie"]){
                NSLog(@"got a movie");
                NSURL *videoURL = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
                
                NSString *path=[[[inscriptsAppDelegate sharedAppDelegate] applicationCacheDirectory] stringByAppendingPathComponent:@"i2i_Videos"];
                path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"uploadVideo.mp4"]];
                
                NSData *webData = [NSData dataWithContentsOfURL:videoURL];
                [webData writeToFile:path atomically:YES];
                
                NSString *userID =[[NSUserDefaults standardUserDefaults]objectForKey:LOGGED_IN_USER];

                [self videoUpload:userID];
                
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];

    }else{
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        imgProfilePic.image = chosenImage;
        
        NSString *path = [[inscriptsAppDelegate sharedAppDelegate] applicationCacheDirectory];
        path = [path stringByAppendingPathComponent:@"i2i.png"];
        
        NSData *imageData1 = UIImagePNGRepresentation(chosenImage);
        [imageData1 writeToFile:path atomically:YES];
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
        NSString *userID =[[NSUserDefaults standardUserDefaults]objectForKey:LOGGED_IN_USER];

        [self imageUpload:userID];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    profilePic = NO;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imageUpload:(NSString *)userId
{
    /*URL: http://i2iapp.com/chat/api/index.php
     1) Add Image
     action=addimage
     image=<ImageFile>
     userid=<current_user_id>
     api-key=c00eaa64e2ac3eabb7ddbdb33ca9b681*/
    
    [appDelegates showLoadingView];
    
    for (ASIHTTPRequest *runningRequest in ASIHTTPRequest.sharedQueue.operations){
        [runningRequest cancel];
        [runningRequest setDelegate:nil];
    }
    
    NSURL *strUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?action=addimage", API_URL]];
    
    upImgRequest = [[ASIFormDataRequest alloc] initWithURL:strUrl];
    [upImgRequest setRequestMethod:@"POST"];
    [upImgRequest setPostFormat:ASIMultipartFormDataPostFormat];
    
    [upImgRequest setTimeOutSeconds:100];
    
    NSString *path = [[inscriptsAppDelegate sharedAppDelegate] applicationCacheDirectory];
    path = [path stringByAppendingPathComponent:@"i2i.png"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path] == YES)
    {
        [upImgRequest setFile:path
            withFileName:@"thumb.png"
          andContentType:@"image/jpeg"
                  forKey:@"image"];
    }
    [upImgRequest setPostValue:userId forKey:@"userid"];
    [upImgRequest setPostValue:USER_KEYS forKey:@"api-key"];
        
    [upImgRequest addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [upImgRequest setUseCookiePersistence:NO];
    [upImgRequest setUseSessionPersistence:NO];
    [upImgRequest setDelegate:self];
    [upImgRequest setDidFinishSelector:@selector(uploadImageRequestFinished:)];
    [upImgRequest setDidFailSelector:@selector(uploadImageRequestFailed:)];
    [upImgRequest setShouldContinueWhenAppEntersBackground:YES];
    [upImgRequest setShowAccurateProgress:YES];
    [upImgRequest setShouldContinueWhenAppEntersBackground:YES];
    [upImgRequest startAsynchronous];
}

- (void)uploadImageRequestFinished:(ASIHTTPRequest *)requestSignUp
{
    NSLog(@"Responce >>> %@",requestSignUp);
    [appDelegates hideLoadingView];
    
    NSString *userID =[[NSUserDefaults standardUserDefaults]objectForKey:LOGGED_IN_USER];

    [self checkAPI:userID];
}
- (void)uploadImageRequestFailed:(ASIHTTPRequest *)request1
{
    [appDelegates hideLoadingView];
    NSError *error = [request1 error];
    NSLog(@">>>>>>>>>>>>> error :%@", error);
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Failed"
                                  message:@"Error"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)videoUpload:(NSString *)userId
{
    /*
     Add Video
     action=addvideo
     video=<VideoFile>
     thumb=<ThumbnailFile>
     userid=<current_user_id>
     api-key=c00eaa64e2ac3eabb7ddbdb33ca9b681
     */
    
    NSString *videoUrl=[[[inscriptsAppDelegate sharedAppDelegate] applicationCacheDirectory] stringByAppendingPathComponent:@"i2i_Videos"];
    videoUrl = [videoUrl stringByAppendingPathComponent:[NSString stringWithFormat:@"uploadVideo.mp4"]];
    
    // Save TMP image to Directory
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoUrl]];
    UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    [player stop];
    
    NSData *imagdata = UIImageJPEGRepresentation(thumbnail, 1.0);
    NSString *imagePath = [[[inscriptsAppDelegate sharedAppDelegate] applicationCacheDirectory] stringByAppendingPathComponent:@"Images"];
    imagePath = [imagePath stringByAppendingPathComponent:@"RecodedVideo.png"];
    [imagdata writeToFile:imagePath atomically:YES];
    
    [appDelegates showLoadingView];
    
    NSURL *strUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@action=addvideo",API_URL]];
    
    upImgRequest = [[ASIFormDataRequest alloc] initWithURL:strUrl];
    [upImgRequest setRequestMethod:@"POST"];
    [upImgRequest setPostFormat:ASIMultipartFormDataPostFormat];
    [upImgRequest setTimeOutSeconds:60000];
    
    NSString *path = [[inscriptsAppDelegate sharedAppDelegate] applicationCacheDirectory];
    path = [path stringByAppendingPathComponent:@"RecodedVideo.png"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:videoUrl] == YES)
    {
        NSLog(@"123 %@",videoUrl);
        
        [upImgRequest setFile:videoUrl
            withFileName:@"1.mp4"
          andContentType:@"video/mp4"
                  forKey:@"video"];
        [upImgRequest setFile:path
                 withFileName:@"thumb.png"
               andContentType:@"image/jpeg"
                       forKey:@"thumb"];
    }
    
    [upImgRequest setPostValue:userId forKey:@"userid"];
    [upImgRequest setPostValue:USER_KEYS forKey:@"api-key"];

    [upImgRequest addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [upImgRequest setUseCookiePersistence:NO];
    [upImgRequest setUseSessionPersistence:NO];
    [upImgRequest setDelegate:self];
    [upImgRequest setDidFinishSelector:@selector(requestFinishedUploadVideo:)];
    [upImgRequest setDidFailSelector:@selector(requestFailedUploadVideo:)];
    [upImgRequest setUploadProgressDelegate:self];
    [upImgRequest setShowAccurateProgress:YES];
    [upImgRequest setShouldContinueWhenAppEntersBackground:YES];
    [upImgRequest startAsynchronous];
}

- (void)requestFinishedUploadVideo:(ASIHTTPRequest *)requestUpload
{
    NSLog(@"Responce >>> %@",requestUpload);
    [appDelegates hideLoadingView];
}
- (void)requestFailedUploadVideo:(ASIHTTPRequest *)request1
{
    [appDelegates hideLoadingView];
    NSError *error = [request1 error];
    NSLog(@">>>>>>>>>>>>> error :%@", error);
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Failed"
                                  message:@"Error"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)onClickEditUserNameBtn:(id)sender {
    txtUserName.userInteractionEnabled = YES;
}

- (IBAction)onClickEditStatusBtn:(id)sender {
    txtStatus.userInteractionEnabled = YES;
}

- (IBAction)onClickAddMediaBtn:(id)sender {
    
}

- (IBAction)onClickImageRightBtn:(id)sender {
    
}

- (IBAction)onClickImageLeftBtn:(id)sender {
    
}

- (IBAction)onClickVideoRightBtn:(id)sender {
    
}

- (IBAction)onClickVideoLeftBtn:(id)sender {
    
}

#pragma mark - UICollectionView Datasource
#pragma mark -

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    if(view == objImageCollection){
        return [arrImage count];
    }else{
        return [arrVideo count];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == objImageCollection){
        ImageCell *cell = [collectionView
                           dequeueReusableCellWithReuseIdentifier:@"cell"
                           forIndexPath:indexPath];
        
        cell.delegate = self;
        cell.index = (int) indexPath.row;
        cell.isImage = YES;
        [cell setImageDict:[arrImage objectAtIndex:indexPath.row]];
        return cell;
    }
    
    ImageCell *cell = [collectionView
                       dequeueReusableCellWithReuseIdentifier:@"cell"
                       forIndexPath:indexPath];
    [cell setVidDict:[arrVideo objectAtIndex:indexPath.row]];
    cell.delegate = self;
    cell.index = (int) indexPath.row;
    cell.isImage = NO;
    
    return cell;
    
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width,collectionView.frame.size.height);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView == objImageCollection){
        CGFloat pageWidth = objImageCollection.frame.size.width;
        imageIndex = objImageCollection.contentOffset.x / pageWidth;
    }else {
        CGFloat pageWidth = objVideoCollection.frame.size.width;
        videoIndex = objVideoCollection.contentOffset.x / pageWidth;
    }
}


-(void)removeImageAtIndex:(int)index
{
    if([arrImage count] > index){
        NSDictionary *dict =[arrImage objectAtIndex:index];
        NSString *userID =[[NSUserDefaults standardUserDefaults]objectForKey:LOGGED_IN_USER];

        [self deleteImageWithImageId:[dict objectForKey:@"image_id"] userId:userID];
    }
}
-(void)removeVideoAtIndex:(int)index
{
    if([arrVideo count] > index){
        NSDictionary *dict =[arrVideo objectAtIndex:index];
        NSString *userID =[[NSUserDefaults standardUserDefaults]objectForKey:LOGGED_IN_USER];
        
        [self deleteVideoAtImage:[dict objectForKey:@"video_id"] userId:userID];
    }
}

-(void)deleteImageWithImageId:(NSString *)imgId userId:(NSString *)userId
{
    /*
     action=removeimage
     imageid=<image_id>
     userid=<current_user_id>
     api-key=c00eaa64e2ac3eabb7ddbdb33ca9b681
     */
    
    if(httpDeleteImg)
    {
        [httpDeleteImg cancelRequest];
        httpDeleteImg.delegate = nil;
        httpDeleteImg = nil;
    }
    httpDeleteImg = [[HttpWrapper alloc] init];
    httpDeleteImg.delegate=self;
    
    [appDelegates showLoadingView];
    
    NSMutableDictionary *dics = [[NSMutableDictionary alloc]init];
    [dics setValue:@"removeimage" forKey:@"action"];
    [dics setValue:imgId forKey:@"imageid"];
    [dics setValue:userId forKey:@"userid"];
    [dics setValue:USER_KEYS forKey:@"api-key"];
    NSLog(@"%@", dics);
    [httpDeleteImg requestWithMethod:@"POST" url:API_URL param:dics];
}

-(void)deleteVideoAtImage:(NSString *)vidId userId:(NSString *)userId
{
    /*
    action=removevideo
    videoid=<video_id>
    userid=<current_user_id>
    api-key=c00eaa64e2ac3eabb7ddbdb33ca9b681
     */
    if(httpDeleteVid)
    {
        [httpDeleteVid cancelRequest];
        httpDeleteVid.delegate = nil;
        httpDeleteVid = nil;
    }
    httpDeleteVid = [[HttpWrapper alloc] init];
    httpDeleteVid.delegate=self;
    
    [appDelegates showLoadingView];
    
    NSMutableDictionary *dics = [[NSMutableDictionary alloc]init];
    [dics setValue:@"removevideo" forKey:@"action"];
    [dics setValue:vidId forKey:@"videoid"];
    [dics setValue:userId forKey:@"userid"];
    [dics setValue:USER_KEYS forKey:@"api-key"];
    NSLog(@"%@", dics);
    [httpDeleteVid requestWithMethod:@"POST" url:API_URL param:dics];

}


- (IBAction)onClickSaveBtn:(id)sender {
    
    txtUserName.userInteractionEnabled = NO;
    txtStatus.userInteractionEnabled = NO;
}

-(IBAction)onClickNextImage:(id)sender
{
    if([arrImage count]-1 > imageIndex){
        imageIndex++;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:imageIndex inSection:0];
        [objImageCollection scrollToItemAtIndexPath:indexPath
                                   atScrollPosition:UICollectionViewScrollPositionNone
                                           animated:YES];
    }
    
}
-(IBAction)onClickPreviousImage:(id)sender
{
    if(imageIndex > 0){
        imageIndex --;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:imageIndex inSection:0];
        [objImageCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

-(IBAction)onClickNextVideo:(id)sender
{
    if([arrVideo count]-1 > videoIndex){
        videoIndex++;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:videoIndex inSection:0];
        [objVideoCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

-(IBAction)onClickPreviusVideo:(id)sender
{
    if(videoIndex > 0){
        videoIndex --;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:videoIndex inSection:0];
        [objVideoCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
