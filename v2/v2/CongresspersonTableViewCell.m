//
//  CongresspersonTableViewCell.m
//  v2
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "CongresspersonTableViewCell.h"
#import "RepManager.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface CongresspersonTableViewCell() <UIAlertViewDelegate, MFMailComposeViewControllerDelegate >
@property (strong, nonatomic) Congressperson *congressperson;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@end

@implementation CongresspersonTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = self.photo.frame.size.width / 2;
    
    self.photo.clipsToBounds = YES;
    
    // ADD SHADOW
    self.shadowView.backgroundColor = [UIColor clearColor];
    self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeMake(0,2.5);
    self.shadowView.layer.shadowOpacity = 0.5;
    self.shadowView.layer.shadowRadius = 3.0;
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds cornerRadius:100.0].CGPath;
    [self.shadowView addSubview:self.photo];
}

- (void)initFromIndexPath:(NSIndexPath*)indexPath {
    self.congressperson =  [RepManager sharedInstance].listOfCongressmen[indexPath.row];
    self.name.text = [NSString stringWithFormat:@"%@ %@", self.congressperson.firstName, self.congressperson.lastName];
    self.photo.image = [UIImage imageWithData:self.congressperson.photo];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)callButtonDidPress:(id)sender {
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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSLog(@"No");
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
- (IBAction)emailButtonDidPress:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:nil];
}


@end