//
//  RepDetailViewController.m
//  Voices
//
//  Created by Ben Rosenfeld on 8/25/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepDetailViewController.h"

@implementation RepDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden:NO];

    self.title = @"More Info";

    self.tweetButton.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.callButton.tintColor = [UIColor voicesOrange];
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    
    self.repImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.repImageView.layer.cornerRadius = 5;
    self.repImageView.clipsToBounds = YES;
    
    [self setFont];
    [self fillInData];
    [self setImage];
}

-(void)setImage {
    UIImage *placeholderImage;
    if(self.representative.gender){
        if ([self.representative.gender isEqualToString:@"M"]) {
            placeholderImage = [UIImage imageNamed:kRepDefaultImageMale];
        }
        else {
            placeholderImage = [UIImage imageNamed:kRepDefaultImageFemale];
        }
    }
    else {
        if ( drand48() < 0.5 ){
            placeholderImage  = [UIImage imageNamed:kRepDefaultImageMale];
        } else {
            placeholderImage  = [UIImage imageNamed:kRepDefaultImageFemale];
        }
    }
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.representative.photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.repImageView setImageWithURLRequest:imageRequest placeholderImage:placeholderImage success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        self.repImageView.image = image;
      
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Federal image failure");
    }];
}

-(void)setFont {
    self.repName.font = self.repName.text.length > 15 ? [UIFont voicesFontWithSize:26] : [UIFont voicesFontWithSize:28];
    self.repName.textColor = [UIColor voicesBlack];
    
    self.repTitle.font = self.repTitle.text.length > 15 ? [UIFont voicesFontWithSize:26] : [UIFont voicesFontWithSize:28];
    self.repTitle.textColor = [UIColor voicesBlack];
    
    self.repPartyDistrict.font = self.repPartyDistrict.text.length > 15 ? [UIFont voicesFontWithSize:26] : [UIFont voicesFontWithSize:28];
    self.repPartyDistrict.textColor = [UIColor voicesBlack];
    
    self.nextElection.font = self.nextElection.text.length > 15 ? [UIFont voicesFontWithSize:26] : [UIFont voicesFontWithSize:28];
    self.nextElection.textColor = [UIColor voicesBlack];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fillInData{
    [self.representative generateDistrictName];
    [self createWithRepresentative];
}

- (IBAction)didPressCallButton:(id)sender {
    if (self.representative.phone) {
        NSString *confirmCallMessage;

        confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@, do you know what to say?", self.repName.text];
        
        UIAlertView *confirmCallAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ %@", self.repTitle.text,self.repName.text]  message:confirmCallMessage delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmCallAlert show];
        confirmCallAlert.delegate = self;
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This legislator hasn't given us their phone number, try tweeting at them instead." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}

- (IBAction)didPressEmailButton:(id)sender {
    if (self.representative.email) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.representative.email];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This legislator hasn't given us their email address, try calling instead." delegate:nil cancelButtonTitle:@"Good Idea" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)didPressTweetButton:(id)sender {
    NSURL *tURL = [NSURL URLWithString:@"twitter://"];
    if ( [[UIApplication sharedApplication] canOpenURL:tURL] ) {
        if (self.representative.twitter) {
            NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.representative.twitter, @"accountName", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"presentTweetComposer" object:nil userInfo:userInfo];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This legislator hasn't given us their Twitter handle, try calling instead." delegate:nil cancelButtonTitle:@"Good Idea" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please install Twitter first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)createWithRepresentative{
    
    if([self.representative.nextElection length]>1){
        self.nextElection.text = [NSString stringWithFormat:@"Next election on %@",self.representative.nextElection ];
    }
    else{
        self.nextElection.text = @"Next election unknown";
    }
    
    self.repTitle.text = self.representative.title;
    self.repName.text = [NSString stringWithFormat:@"%@", self.representative.fullName];
    
    if([self.representative.party isEqualToString:@"D"]){
        self.repPartyDistrict.text = @"Democrat";
    }
    else if([self.representative.party isEqualToString:@"R"]){
        self.repPartyDistrict.text = @"Republican\n";
    }
    
    if(self.representative.districtFullName && ![self.representative.title  isEqual: @"Senator"]){
        self.repPartyDistrict.text = [self.repPartyDistrict.text stringByAppendingString:[NSString stringWithFormat:@" %@",self.representative.districtFullName]];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
    }
    else if (buttonIndex == 1) {
        
        //[FIRAnalytics logEventWithName:@"phoneCall" parameters:@{@"name" : self.repName.text, kFIRParameterValue : @1}];
        
        NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@", self.representative.phone]];
        if([[UIApplication sharedApplication] canOpenURL:callUrl]) {
            
            [[UIApplication sharedApplication] openURL:callUrl];
            
        }
        else {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"This representative hasn't given us their phone number"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
