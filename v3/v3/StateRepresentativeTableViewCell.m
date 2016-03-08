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

@interface StateRepresentativeTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (strong, nonatomic) StateRepresentative *stateRepresentative;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *districtNumberLabel;
@property (strong, nonatomic) NSArray *listOfStatesWithAssembly;
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

// THIS IS A BREACH OF MVC
- (void)initFromIndexPath:(NSIndexPath*)indexPath {
    self.stateRepresentative =  [RepManager sharedInstance].listOfStateRepresentatives[indexPath.row];
    self.name.text = [NSString stringWithFormat:@"%@ %@ %@", self.stateRepresentative.chamber, self.stateRepresentative.firstName, self.stateRepresentative.lastName];
    [self createDistrictNumberLabel];
    self.photo.image = [UIImage imageWithData:self.stateRepresentative.photo];
}

- (void)setColor {
    self.emailButton.imageView.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.callButton.tintColor = [UIColor voicesOrange];
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
        [self.delegate presentCustomAlertWithMessage:@"This legislator does not have a phone number listed.\n\n Try tweeting instead" andTitle:[NSString stringWithFormat:@"%@. %@", self.stateRepresentative.firstName, self.stateRepresentative.lastName]];
    }
}
- (IBAction)emailButtonDidPress:(id)sender {
    if (self.stateRepresentative.email.length > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.stateRepresentative.email];
    }
    else {
        [self.delegate presentCustomAlertWithMessage:@"This legislator does not have an email listed.\n\n Try calling instead, it's more effective."andTitle:[NSString stringWithFormat:@"%@. %@", self.stateRepresentative.firstName, self.stateRepresentative.lastName]];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
    }
    else if (buttonIndex == 1) {
        NSURL *callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@", self.stateRepresentative.phone]];
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
@end