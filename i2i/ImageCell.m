//
//  ImageCell.m
//  SDKTestApp
//
//  Created by Darshan on 03/08/16.
//  Copyright © 2016 inscripts. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell

@synthesize imgCollection;

@synthesize delegate;
@synthesize index;
@synthesize isImage;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    viewBack.layer.borderWidth = 0.5f;
    viewBack.layer.borderColor = [UIColor lightGrayColor].CGColor;
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
        [imgCollection loadImageFromStringforUserimg:imageName];
    }
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
        [imgCollection loadImageFromStringforUserimg:imageName];
    }
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

@end
