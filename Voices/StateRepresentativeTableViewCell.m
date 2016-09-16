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
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "AlignedLabel.h"

@import FirebaseAnalytics;

@interface StateRepresentativeTableViewCell ()

@property (strong, nonatomic) StateRepresentative *stateRepresentative;
@property (strong, nonatomic) NSArray *listOfStatesWithAssembly;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet AlignedLabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@end

@implementation StateRepresentativeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = kButtonCornerRadius;
    self.photo.clipsToBounds = YES;
    [self setFont];
    [self setColor];
    self.listOfStatesWithAssembly = [NSArray arrayWithObjects:@"CA", @"NV", @"NJ", @"NY", @"WI", nil];
}

- (void)initWithRep:(id)rep {
    self.stateRepresentative = rep;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@ %@", self.stateRepresentative.chamber, self.stateRepresentative.firstName, self.stateRepresentative.lastName];
    [self setImage];
}

- (void)setImage{
    UIImage *placeholderImage;
    if (self.stateRepresentative.gender) {
        if ([self.stateRepresentative.gender isEqualToString:@"M"]) {
            placeholderImage  = [UIImage imageNamed:kRepDefaultImageMale];
        }
        else {
            placeholderImage  = [UIImage imageNamed:kRepDefaultImageFemale];
        }
    }
    else {
        if ( drand48() < 0.5 ){
            placeholderImage  = [UIImage imageNamed:kRepDefaultImageMale];
        } else {
            placeholderImage  = [UIImage imageNamed:kRepDefaultImageFemale];
        }
    }

    
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.stateRepresentative.photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.photo setImageWithURLRequest:imageRequest placeholderImage:placeholderImage success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
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

- (void)setFont {
    self.nameLabel.font = self.nameLabel.text.length > 15 ? [UIFont voicesFontWithSize:26] : [UIFont voicesFontWithSize:28];
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
        UIAlertView *confirmCallAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ %@ %@", self.stateRepresentative.chamber ,self.stateRepresentative.firstName, self.stateRepresentative.lastName]  message:confirmCallMessage delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmCallAlert show];
        confirmCallAlert.delegate = self;
    }
    else {
        UIAlertView *phoneAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Representative %@ %@",self.stateRepresentative.firstName, self.stateRepresentative.lastName]  message:@"This representative doesn't have their phone number listed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [phoneAlert show];
    }
}

- (IBAction)emailButtonDidPress:(id)sender {
    if (self.stateRepresentative.email != nil && ([self.stateRepresentative.email isKindOfClass:[NSString class]]) && self.stateRepresentative.email.length > 0 ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.stateRepresentative.email];
    }
    else {
        
        UIAlertView *emailAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Representative %@ %@",self.stateRepresentative.firstName, self.stateRepresentative.lastName]  message:@"This representative doesn't have their email listed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [emailAlert show];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This legislator hasn't given us their Twitter handle, try calling instead." delegate:nil cancelButtonTitle:@"Good Idea" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please install Twitter first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
    }
    else if (buttonIndex == 1) {
        
        [FIRAnalytics logEventWithName:@"phoneCall" parameters:@{@"name" : self.stateRepresentative.fullName, kFIRParameterValue : @1}];
        
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
@end
