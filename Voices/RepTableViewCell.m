//
//  RepTableViewCell.h
//  Voices
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "RepTableViewCell.h"
#import "RepManager.h"
#import "UIImageView+AFNetworking.h"
#import "Representative.h"
#import <MessageUI/MFMailComposeViewController.h>

@import FirebaseAnalytics;

@interface RepTableViewCell() <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) Representative *representative;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;

@end

@implementation RepTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.photo.backgroundColor = [UIColor clearColor];
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = 5;
    self.photo.clipsToBounds = YES;
    [self setFont];
}

- (void)setFont {
    self.name.font = self.name.text.length > 15 ? [UIFont voicesFontWithSize:26] : [UIFont voicesFontWithSize:28];
    self.name.textColor = [UIColor voicesBlack];
}

- (void)initWithRep:(id)rep {
    self.representative = rep;
    NSString *title = self.representative.shortTitle ? self.representative.shortTitle : self.representative.title;
    self.name.text = [NSString stringWithFormat:@"%@ %@ %@", title, self.representative.firstName, self.representative.lastName];
    self.tweetButton.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.callButton.tintColor = [UIColor voicesOrange];
    [self setImage];
}

- (void)setImage {
    
    UIImage *placeholderImage;
    if ([self.representative.gender isEqualToString:@"M"]) {
        placeholderImage = [UIImage imageNamed:kRepDefaultImageMale];
    }
    else {
        placeholderImage = [UIImage imageNamed:kRepDefaultImageFemale];
    }
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.representative.photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.photo setImageWithURLRequest:imageRequest placeholderImage:placeholderImage success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        self.photo.image = image;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Federal image failure");
    }];
}


#pragma mark - User Actions

- (IBAction)callButtonDidPress:(id)sender {
    
    if (self.representative.phone.length) {
        NSString *confirmCallMessage;
        if (self.representative.nickname != nil && ![self.representative.nickname isEqual:[NSNull null]]) {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@, do you know what to say?", self.representative.nickname];
        }
        else {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@ %@, do you know what to say?", self.representative.firstName, self.representative.lastName];
        }
        
        UIAlertController *confirmCallAlertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@ %@", self.representative.title,self.representative.firstName, self.representative.lastName]  message:confirmCallMessage preferredStyle:UIAlertControllerStyleAlert];
        //button0
        [confirmCallAlertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
        }]];
        //button1
        [confirmCallAlertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [FIRAnalytics logEventWithName:@"phoneCall" parameters:@{@"name" : self.representative.fullName, kFIRParameterValue : @1}];
            NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@", self.representative.phone]];
            if([[UIApplication sharedApplication] canOpenURL:callUrl]) {
                
                [[UIApplication sharedApplication] openURL:callUrl];
                
            }
            else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This representative hasn't given us their phone number." preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
            }
            }]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:confirmCallAlertController animated:YES completion:nil];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This legislator hasn't given us their phone number, try tweeting at them instead." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)emailButtonDidPress:(id)sender {
    
    if (self.representative.email.length) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.representative.email];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This legislator hasn't given us their email address, try calling instead." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Good idea" style:UIAlertActionStyleDefault handler:nil]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)tweetButtonDidPress:(id)sender {
    
    NSURL *tURL = [NSURL URLWithString:@"twitter://"];
    if ( [[UIApplication sharedApplication] canOpenURL:tURL] ) {
        if (self.representative.twitter) {
            NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.representative.twitter, @"accountName", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"presentTweetComposer" object:nil userInfo:userInfo];
        }
        else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This legislator hasn't given us their Twitter handle, try calling instead." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Good idea" style:UIAlertActionStyleDefault handler:nil]];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
        }
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"Please install Twitter first." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

@end
