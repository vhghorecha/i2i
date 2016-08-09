//
//  ImageCell.m
//  SDKTestApp
//
//  Created by Darshan on 03/08/16.
//  Copyright © 2016 inscripts. All rights reserved.
//

#import "ImageCell.h"
#import "UIImageView+AFNetworking.h"

@implementation ImageCell

@synthesize imgCollection;

@synthesize delegate;
@synthesize index;
@synthesize isImage;
@synthesize strLinkVideo;
@synthesize strLinkImage;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    viewBack.layer.borderWidth = 0.5f;
    viewBack.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] init];
    [singleTap setNumberOfTapsRequired:1];
    imgCollection.userInteractionEnabled = YES;
    [singleTap addTarget:self action:@selector(playVideoOnMPMoviePlayer)];
    [imgCollection addGestureRecognizer:singleTap];
}

-(void)setImageDict:(NSDictionary *)dict
{
    dictContent = dict;
    //[imgCollection loadImageWithURl:[dict objectForKey:@"image_url"] andPlaceHolderImage:nil];
    NSString *imageName;
    if ([dict objectForKey:@"image_url"] == nil || [[dict objectForKey:@"image_url"] isEqualToString:@""] || [[dict objectForKey:@"image_url"] isKindOfClass:[NSNull class]]) {
        imgCollection.image = [UIImage imageNamed:@"btnPlaceHolder.png"];
    }else{
        imageName = [NSString stringWithFormat:@"%@",[dict objectForKey:@"image_url"]];
        
        if(![imageName hasPrefix:@"http://www"]) {
            [imgCollection setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.%@", imageName]] placeholderImage:nil];
        }else{
            [imgCollection setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:nil];
        }
    }
    strLinkImage = [NSString stringWithFormat:@"http://www.%@",imageName];
}

-(void)setVidDict:(NSDictionary *)dict
{
    dictContent = dict;
    //[imgCollection loadImageWithURl:[dict objectForKey:@"video_thumb"] andPlaceHolderImage:nil];
    NSString *imageName;
    if ([dict objectForKey:@"video_thumb"] == nil || [[dict objectForKey:@"video_thumb"] isEqualToString:@""] || [[dict objectForKey:@"video_thumb"] isKindOfClass:[NSNull class]]) {
        imgCollection.image = [UIImage imageNamed:@"btnPlaceHolder.png"];
    }else{
        imageName = [NSString stringWithFormat:@"%@",[dict objectForKey:@"video_thumb"]];
        
        if(![imageName hasPrefix:@"http://www"]) {
            [imgCollection setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.%@", imageName]] placeholderImage:nil];
        }else{
            [imgCollection setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:nil];
        }
    }
    strLinkVideo = [NSString stringWithFormat:@"http://www.%@",imageName];
}

-(IBAction)onClickClose:(id)sender
{
    if(isImage){
        if(delegate && [delegate respondsToSelector:@selector(removeImageAtIndex:)]){
            [delegate removeImageAtIndex:index];
        }
    }else{
        if(delegate && [delegate respondsToSelector:@selector(removeVideoAtIndex:)]){
            [delegate removeVideoAtIndex:index];
        }
    }
}

-(void)playVideoOnMPMoviePlayer
{
    if (isImage) {
        if (delegate && [delegate respondsToSelector:@selector(showImageAtIndex:andImage:)]) {
            [delegate showImageAtIndex:index andImage:strLinkImage];
        }
    }else{
        if (delegate && [delegate respondsToSelector:@selector(playVideoAtIndex:andVideo:)]) {
            [delegate playVideoAtIndex:index andVideo:strLinkVideo];
        }
    }
}
@end
