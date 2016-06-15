//
//  StateRepresentativeTableViewCell.m
//  Voices
//
//  Created by John Bogil on 10/16/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "StateRepresentativeTableViewCell.h"
#import "RepManager.h"
#import "StateRepresentative.h"
#import "UIFont+voicesFont.h"
#import "UIColor+voicesOrange.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Google/Analytics.h>


@interface StateRepresentativeTableViewCell ()

@property (strong, nonatomic) StateRepresentative *stateRepresentative;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *districtNumberLabel;
@property (strong, nonatomic) NSArray *listOfStatesWithAssembly;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;

@end

@implementation StateRepresentativeTableViewCell

- (void)awakeFromNib {
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = 5;
    self.photo.clipsToBounds = YES;
    [self setFont];
    [self setColor];
    self.listOfStatesWithAssembly = [NSArray arrayWithObjects:@"CA", @"NV", @"NJ", @"NY", @"WI", nil];
}

- (void)initWithRep:(id)rep {
    self.stateRepresentative = rep;
    self.name.text = [NSString stringWithFormat:@"%@ %@ %@", self.stateRepresentative.chamber, self.stateRepresentative.firstName, self.stateRepresentative.lastName];
    [self createDistrictNumberLabel];
    [self setImage];
}

- (void)setImage{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.stateRepresentative.photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.photo setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"MissingRep"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        self.photo.image = image;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"State image failure");
    }];
}

- (void)setColor {
    self.emailButton.imageView.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.callButton.tintColor = [UIColor voicesOrange];
    self.tweetButton.tintColor = [UIColor voicesOrange];
}

- (void)createDistrictNumberLabel {
    if ([self.stateRepresentative.chamber isEqualToString:@"Rep."]) {
        if ([self.listOfStatesWithAssembly containsObject:self.stateRepresentative.stateCode.uppercaseString]) {
            self.districtNumberLabel.text = [NSString stringWithFormat:@"Assembly District %@", self.stateRepresentative.districtNumber];
        }
        else {
            self.districtNumberLabel.text = [NSString stringWithFormat:@"House District %@", self.stateRepresentative.districtNumber];
        }
    }
    else if ([self.stateRepresentative.chamber isEqualToString:@"Gov."]) {
        if (self.stateRepresentative.nextElection) {
            self.districtNumberLabel.text = [NSString stringWithFormat:@"Next Election: %@",self.stateRepresentative.nextElection];
        } else {
            self.districtNumberLabel.text = @"";
       }
    }
    else {
        self.districtNumberLabel.text = [NSString stringWithFormat:@"Senate District %@", self.stateRepresentative.districtNumber];
    }
}

- (void)setFont {
    self.name.font = [UIFont voicesFontWithSize:24];
    self.districtNumberLabel.font = [UIFont voicesFontWithSize:20];
}

- (IBAction)callButtonDidPress:(id)sender {
    if (self.stateRepresentative.phone) {
        NSString *confirmCallMessage;
        if (![self.stateRepresentative.firstName isEqual:[NSNull null]]) {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@, do you know what to say?", self.stateRepresentative.firstName];
        }
        else {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@ %@, do you know what to say?", self.stateRepresentative.firstName, self.stateRepresentative.lastName];
        }
        UIAlertView *confirmCallAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Representative %@ %@",self.stateRepresentative.firstName, self.stateRepresentative.lastName]  message:confirmCallMessage delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmCallAlert show];
        confirmCallAlert.delegate = self;
    }
    else {
        UIAlertView *phoneAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Representative %@ %@",self.stateRepresentative.firstName, self.stateRepresentative.lastName]  message:@"This representative doesn't have their phone number listed" delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil];
        [phoneAlert show];
    }
}

- (IBAction)emailButtonDidPress:(id)sender {
    if (self.stateRepresentative.email != nil && ([self.stateRepresentative.email isKindOfClass:[NSString class]]) && self.stateRepresentative.email.length > 0 ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.stateRepresentative.email];
    }
    else {
        
        UIAlertView *emailAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Representative %@ %@",self.stateRepresentative.firstName, self.stateRepresentative.lastName]  message:@"This representative doesn't have their email listed" delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil];
        [emailAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
    }
    else if (buttonIndex == 1) {
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                              action:@"phone call"
                                                               label:self.stateRepresentative.fullName
                                                               value:@1] build]];
        
        
        NSURL *callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@", self.stateRepresentative.phone]];
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
- (IBAction)tweetButton:(id)sender {
    NSURL *tURL = [NSURL URLWithString:@"twitter://"];
    if ( [[UIApplication sharedApplication] canOpenURL:tURL] ) {
        if (self.stateRepresentative.twitter) {
            NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.stateRepresentative.twitter, @"accountName", nil];
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
@end