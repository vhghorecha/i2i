//
//  VideoChatViewController.m
//  SDKTestApp
//
//  Created by Inscripts on 06/04/15.
//  Copyright (c) 2015 inscripts. All rights reserved.
//

#import "VideoChatViewController.h"

@interface VideoChatViewController (){
    
    GroupAVChat *groupAVChat;
}

@end

@implementation VideoChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    groupAVChat = [[GroupAVChat alloc] init];
    
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [groupAVChat startConferenceInContainer:self.videoView changeInAudioRoute:^(NSDictionary *audioRouteInformation) {
        NSLog(@"SDK log : Change in Audio route = %@",audioRouteInformation);
    } failure:^(NSError *error) {
         NSLog(@"SDK log: START AV CONFERENCE FAILURE %@",error);
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)endAction:(id)sender {
    
    
    [groupAVChat endConference:^(NSDictionary *response) {
        
        NSLog(@"SDK log: END CONFERENCE FAILURE %@",response);
        
        [self.navigationController popViewControllerAnimated:NO];
        
    } failure:^(NSError *error) {
        NSLog(@"SDK log: END CONFERENCE FAILURE %@",error);
    }];
    
}


@end
