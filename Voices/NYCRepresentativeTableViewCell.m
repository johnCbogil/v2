//
//  NYCRepresentativeTableViewCell.m
//  Voices
//
//  Created by John Bogil on 1/24/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NYCRepresentativeTableViewCell.h"
#import "NYCRepresentative.h"
#import "RepManager.h"


@import FirebaseAnalytics;

@interface NYCRepresentativeTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) NYCRepresentative *nycRepresentative;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation NYCRepresentativeTableViewCell

- (void)awakeFromNib {
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = kButtonCornerRadius;
    self.photo.clipsToBounds = YES;
    [self setFont];
    [self setColor];
}

- (void)setImage{
    UIImage *placeholderImage;
    if ([self.nycRepresentative.gender isEqualToString:@"M"]) {
        placeholderImage = [UIImage imageNamed:kRepDefaultImageMale];
    }
    else {
        placeholderImage = [UIImage imageNamed:kRepDefaultImageFemale];
    }
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.nycRepresentative.photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.photo setImageWithURLRequest:imageRequest placeholderImage:placeholderImage success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        NSLog(@"NYC image success");
        self.photo.image = image;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"NYC image failure");
    }];
}

- (void)setFont {
    self.nameLabel.font = self.nameLabel.text.length > 15 ? [UIFont voicesFontWithSize:26] : [UIFont voicesFontWithSize:28];
}

- (void)setColor {
    self.emailButton.imageView.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.callButton.tintColor = [UIColor voicesOrange];
    self.tweetButton.tintColor = [UIColor voicesOrange];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)initWithRep:(id)rep {
    
    self.nycRepresentative = rep;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.nycRepresentative.title, self.nycRepresentative.fullName];
    [self setImage];
}

#pragma mark - User actions

- (IBAction)tweetButtonDidPress:(id)sender {
    
    NSURL *tURL = [NSURL URLWithString:@"twitter://"];
    if ( [[UIApplication sharedApplication] canOpenURL:tURL] ) {
        if (self.nycRepresentative.twitter) {
            NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.nycRepresentative.twitter, @"accountName", nil];
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


- (IBAction)emailButtonDidPress:(id)sender {
    if (self.nycRepresentative.email.length > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.nycRepresentative.email];
    }
    else {
        NSString *alertMessage;
        if (![self.nycRepresentative.firstName isEqualToString:@"Vacant"]) {
            alertMessage = @"This legislator hasn't given us their email address, try calling them instead.";
        }
        else {
            alertMessage = @"This office is currently vacant.";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (IBAction)phoneButtonDidPress:(id)sender {
    if (![self.nycRepresentative.phone isEqualToString:@""]) {
        NSString *confirmCallTitle = [NSString stringWithFormat:@"%@ %@",self.nycRepresentative.title,self.nycRepresentative.lastName];
        NSString *confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@, do you know what to say?", self.nycRepresentative.fullName];
        
        UIAlertView *confirmCallAlert = [[UIAlertView alloc]initWithTitle:confirmCallTitle  message:confirmCallMessage delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmCallAlert show];
        confirmCallAlert.delegate = self;
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"This office is currently vacant" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
    }
    else if (buttonIndex == 1) {
        
        NSString *fullName = [NSString stringWithFormat:@"%@", self.nycRepresentative.fullName];
        [FIRAnalytics logEventWithName:@"phoneCall" parameters:@{@"name" : fullName, kFIRParameterValue : @1}];
        
        NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@", self.nycRepresentative.phone]];
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