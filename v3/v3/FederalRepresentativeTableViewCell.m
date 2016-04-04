//
//  FederalRepresentativeTableViewCell.m
//  Voices
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "FederalRepresentativeTableViewCell.h"
#import "RepManager.h"
#import "UIFont+voicesFont.h"
#import "UIColor+voicesOrange.h"
#import "UIImageView+AFNetworking.h"
#import <Google/Analytics.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface FederalRepresentativeTableViewCell() <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) FederalRepresentative *federalRepresentative;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UILabel *nextElectionLabel;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (strong, nonnull) CTCallCenter *callCenter;

@end

@implementation FederalRepresentativeTableViewCell

- (void)awakeFromNib {
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = 5;
    self.photo.clipsToBounds = YES;
    [self setFont];
    [self trackConnectedCalls];
}

- (void)setFont {
    self.name.font = [UIFont voicesFontWithSize:24];
    self.nextElectionLabel.font = [UIFont voicesFontWithSize:20];
}

- (void)initWithRep:(id)rep {
    self.federalRepresentative = rep;
    self.name.text = [NSString stringWithFormat:@"%@. %@ %@", self.federalRepresentative.shortTitle, self.federalRepresentative.firstName, self.federalRepresentative.lastName];
    self.nextElectionLabel.text = [NSString stringWithFormat:@"Next Election: %@",self.federalRepresentative.nextElection];
    self.tweetButton.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.callButton.tintColor = [UIColor voicesOrange];
    [self setImage];
}

- (void)setImage{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.federalRepresentative.photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.photo setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"MissingRep"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        self.photo.image = image;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Federal image failure");
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
    }
    else if (buttonIndex == 1) {
        NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@", self.federalRepresentative.phone]];
        if([[UIApplication sharedApplication] canOpenURL:callUrl])
        {
            
            [[UIApplication sharedApplication] openURL:callUrl];
            
        }
        else {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"This representative hasn't given us their phone number"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - User Actions

- (IBAction)callButtonDidPress:(id)sender {
    if (self.federalRepresentative.phone) {
        NSString *confirmCallMessage;
        if (![self.federalRepresentative.nickname isEqual:[NSNull null]]) {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@, do you know what to say?", self.federalRepresentative.nickname];
        }
        else {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@ %@, do you know what to say?", self.federalRepresentative.firstName, self.federalRepresentative.lastName];
        }
        UIAlertView *confirmCallAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ %@ %@", self.federalRepresentative.title,self.federalRepresentative.firstName, self.federalRepresentative.lastName]  message:confirmCallMessage delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmCallAlert show];
        confirmCallAlert.delegate = self;
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This legislator hasn't given us their phone number, try tweeting at them instead." delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)emailButtonDidPress:(id)sender {
    if (self.federalRepresentative.email) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.federalRepresentative.email];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This legislator hasn't given us their email address, try calling instead." delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (IBAction)twitterButtonDidPress:(id)sender {
    
    NSURL *tURL = [NSURL URLWithString:@"twitter://"];
    if ( [[UIApplication sharedApplication] canOpenURL:tURL] ) {
        if (self.federalRepresentative.twitter) {
            NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.federalRepresentative.twitter, @"accountName", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"presentTweetComposer" object:nil userInfo:userInfo];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This legislator hasn't given us their Twitter handle, try calling instead." delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please install Twitter first." delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)trackConnectedCalls {
    self.callCenter = [[CTCallCenter alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.callCenter setCallEventHandler:^(CTCall *call) {
        if ([[call callState] isEqual:CTCallStateConnected]) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"direct_action"     // Event category (required)
                                                                  action:@"federal_call"  // Event action (required)
                                                                   label:weakSelf.federalRepresentative.fullName           // Event label
                                                                   value:@1] build]];    // Event value
        }
    }];
}
@end