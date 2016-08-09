//
//  ImageCell.h
//  SDKTestApp
//
//  Created by Darshan on 03/08/16.
//  Copyright © 2016 inscripts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImage.h"

@protocol ImageCellDelegate <NSObject>

-(void)removeImageAtIndex:(int)index;
-(void)removeVideoAtIndex:(int)index;
-(void)playVideoAtIndex:(int)index andVideo:(NSString *)strVideoLink;
-(void)showImageAtIndex:(int)index andImage:(NSString *)strImageLink;
@end

@interface ImageCell : UICollectionViewCell
{
    IBOutlet UIView *viewBack;
    NSDictionary *dictContent;
    
    IBOutlet UIButton *btnClose;
    
    id<ImageCellDelegate> delegate;
}
@property (nonatomic) BOOL isImage;
@property (nonatomic)int index;
@property (strong ,  nonatomic)id<ImageCellDelegate> delegate;

@property (nonatomic , strong) IBOutlet AsyncImage *imgCollection;
@property (nonnull , strong) NSString *strLinkVideo;
@property (nonnull , strong) NSString *strLinkImage;

-(void)setImageDict:(NSDictionary *)dict;
-(void)setVidDict:(NSDictionary *)dict;

@end
