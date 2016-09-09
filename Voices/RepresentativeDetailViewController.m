//
//  RepresentativeDetailViewController.m
//  Voices
//
//  Created by Ben Rosenfeld on 8/25/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepresentativeDetailViewController.h"

@interface RepresentativeDetailViewController ()

@end

@implementation RepresentativeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"More Info";
    
    self.tweetButton.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.callButton.tintColor = [UIColor voicesOrange];
    
    self.repImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.repImageView.layer.cornerRadius = 5;
    self.repImageView.clipsToBounds = YES;
    
    
    [self setFont];
    [self fillInData];
    [self setImage];
    
}

-(void)setImage{
    UIImage *placeholderImage;
    if ([self.gender isEqualToString:@"M"]) {
        placeholderImage = [UIImage imageNamed:kRepDefaultImageMale];
    }
    else {
        placeholderImage = [UIImage imageNamed:kRepDefaultImageFemale];
    }
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    
    [self.repImageView setImageWithURLRequest:imageRequest placeholderImage:placeholderImage success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        self.repImageView.image = image;
      
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Federal image failure");
    }];
}

-(void)setFont{
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
    // This puts the data in the pictures and labels
    if ([self.repType isEqualToString:@"Federal"]) {
        [self createWithFederal];
    }
    else if ([self.repType isEqualToString:@"State"]) {
        [self createWithState];
    }
    else if ([self.repType isEqualToString:@"NYC"]) {
        [self createWithNYC];
    }
    
}

- (IBAction)didPressCallButton:(id)sender {
    if (self.phone) {
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
    if (self.email) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.email];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This legislator hasn't given us their email address, try calling instead." delegate:nil cancelButtonTitle:@"Good Idea" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)didPressTweetButton:(id)sender {
    NSURL *tURL = [NSURL URLWithString:@"twitter://"];
    if ( [[UIApplication sharedApplication] canOpenURL:tURL] ) {
        if (self.twitter) {
            NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.twitter, @"accountName", nil];
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

-(void)createWithFederal{
    self.phone = self.federalRep.phone;
    self.email = self.federalRep.email;
    self.twitter = self.federalRep.twitter;
    
    if([self.federalRep.nextElection length]>1){
        self.nextElection.text = [NSString stringWithFormat:@"Next election on %@",self.federalRep.nextElection ];
    }
    else{
        self.nextElection.text = @"Next election unknown";
    }
    
    self.repTitle.text = self.federalRep.title;
    self.repName.text = [NSString stringWithFormat:@"%@ %@", self.federalRep.firstName, self.federalRep.lastName];
    self.gender = self.federalRep.gender;
    self.photoURL = self.federalRep.photoURL;
    
    if([self.federalRep.party isEqualToString:@"D"]){
        self.repPartyDistrict.text = @"Democrat";
    }
    else if([self.federalRep.party isEqualToString:@"R"]){
        self.repPartyDistrict.text = @" Republican";
    }
}

-(void)createWithState{
    self.phone = self.stateRep.phone;
    self.email = self.stateRep.email;
    self.twitter = self.stateRep.twitter;
    
    if([self.stateRep.nextElection length]>1){
        self.nextElection.text = [NSString stringWithFormat:@"Next election on %@",self.stateRep.nextElection ];
    }
    else{
        self.nextElection.text = @"Next election unknown";
    }
    
    self.repTitle.text = self.stateRep.chamber;
    self.repName.text = [NSString stringWithFormat:@"%@ %@", self.stateRep.firstName, self.stateRep.lastName];
    self.gender = self.stateRep.gender;
    self.photoURL = self.stateRep.photoURL;
    
    if([self.stateRep.party isEqualToString:@"D"]){
        self.repPartyDistrict.text = @"Democrat";
    }
    else if([self.stateRep.party isEqualToString:@"R"]){
        self.repPartyDistrict.text = @" Republican";
    }
}

-(void)createWithNYC{
    self.phone = self.NYCRep.phone;
    self.email = self.NYCRep.email;
    self.twitter = self.NYCRep.twitter;
    
    if([self.NYCRep.nextElection length]>1){
        self.nextElection.text = [NSString stringWithFormat:@"Next election on %@",self.NYCRep.nextElection ];
    }
    else{
        self.nextElection.text = @"Next election unknown";
    }
    
    self.repTitle.text = self.NYCRep.title;
    self.repName.text = [NSString stringWithFormat:@"%@", self.NYCRep.fullName];
    self.gender = self.NYCRep.gender;
    self.photoURL = self.NYCRep.photoURL;
    
    if([self.NYCRep.party isEqualToString:@"D"]){
        self.repPartyDistrict.text = @"Democrat";
    }
    else if([self.NYCRep.party isEqualToString:@"R"]){
        self.repPartyDistrict.text = @" Republican";
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
    }
    else if (buttonIndex == 1) {
        
        //[FIRAnalytics logEventWithName:@"phoneCall" parameters:@{@"name" : self.repName.text, kFIRParameterValue : @1}];
        
        NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@", self.phone]];
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
