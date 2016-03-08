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
#import <MessageUI/MFMailComposeViewController.h>

@interface FederalRepresentativeTableViewCell() <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) Congressperson *congressperson;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UILabel *nextElectionLabel;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@end

@implementation FederalRepresentativeTableViewCell

- (void)awakeFromNib {
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = 5;
    self.photo.clipsToBounds = YES;
    [self setFont];
}

- (void)setFont {
    self.name.font = [UIFont voicesFontWithSize:24];
    self.nextElectionLabel.font = [UIFont voicesFontWithSize:20];
}

- (void)initFromIndexPath:(NSIndexPath*)indexPath {
    self.congressperson =  [RepManager sharedInstance].listOfCongressmen[indexPath.row];
    self.name.text = [NSString stringWithFormat:@"%@. %@ %@", self.congressperson.shortTitle, self.congressperson.firstName, self.congressperson.lastName];
    self.photo.image = [UIImage imageWithData:self.congressperson.photo];
    self.nextElectionLabel.text = [NSString stringWithFormat:@"Next Election: %@",self.congressperson.nextElection];
    self.tweetButton.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.callButton.tintColor = [UIColor voicesOrange];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
    }
    else if (buttonIndex == 1) {
        NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@", self.congressperson.phone]];
        if([[UIApplication sharedApplication] canOpenURL:callUrl])
        {
            [[UIApplication sharedApplication] openURL:callUrl];
        }
        else {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ALERT" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (IBAction)callButtonDidPress:(id)sender {
    if (self.congressperson.phone) {
        NSString *confirmCallMessage;
        if (![self.congressperson.nickname isEqual:[NSNull null]]) {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@, do you know what to say?", self.congressperson.nickname];
        }
        else {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@ %@, do you know what to say?", self.congressperson.firstName, self.congressperson.lastName];
        }
        UIAlertView *confirmCallAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ %@ %@", self.congressperson.title,self.congressperson.firstName, self.congressperson.lastName]  message:confirmCallMessage delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmCallAlert show];
        confirmCallAlert.delegate = self;
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This legislator hasn't given us their phone number, try tweeting at them instead." delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)emailButtonDidPress:(id)sender {
    if (self.congressperson.email) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.congressperson.email];
    }
    else {
        // RENAME THIS DELEGATE TO BE MORE SPECIFIC
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This legislator hasn't given us their email address, try calling instead." delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (IBAction)twitterButtonDidPress:(id)sender {
    if (self.congressperson.twitter) {
        NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.congressperson.twitter, @"accountName", nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"presentTweetComposer" object:nil userInfo:userInfo];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This legislator hasn't given us their Twitter handle, try calling instead." delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil, nil];
        [alert show];
    }
}
@end