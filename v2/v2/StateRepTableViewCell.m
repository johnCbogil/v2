//
//  StateRepTableViewCell.m
//  v2
//
//  Created by John Bogil on 10/16/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "StateRepTableViewCell.h"
#import "RepManager.h"
#import "StateLegislator.h"
#import "InfoPageViewController.h"
@interface StateRepTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (strong, nonatomic) StateLegislator *stateLegislator;
@end
@implementation StateRepTableViewCell

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
    self.stateLegislator =  [RepManager sharedInstance].listofStateLegislators[indexPath.row];
    self.name.text = [NSString stringWithFormat:@"(%@) - %@ %@", self.stateLegislator.party, self.stateLegislator.firstName, self.stateLegislator.lastName];
    self.photo.image = [UIImage imageWithData:self.stateLegislator.photo];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (IBAction)callButtonDidPress:(id)sender {
    if (self.stateLegislator.phone) {
        NSString *confirmCallMessage;
        if (![self.stateLegislator.firstName isEqual:[NSNull null]]) {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@, do you know what to say?", self.stateLegislator.firstName];
        }
        else {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@ %@, do you know what to say?", self.stateLegislator.firstName, self.stateLegislator.lastName];
        }
        UIAlertView *confirmCallAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Representative %@ %@",self.stateLegislator.firstName, self.stateLegislator.lastName]  message:confirmCallMessage delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmCallAlert show];
        confirmCallAlert.delegate = self;
    }
    else {
        // PRESENT ERROR
    }
}
- (IBAction)emailButtonDidPress:(id)sender {
    if (self.stateLegislator.email) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.stateLegislator.email];
    }
    else {
        // PRESENT ERROR
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [InfoPageViewController sharedInstance].startFromScript = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
    }
    else if (buttonIndex == 1) {
        NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@", self.stateLegislator.phone]];
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