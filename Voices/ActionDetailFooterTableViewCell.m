//
//  ActionDetailFooterTableViewCell.m
//  Voices
//
//  Created by John Bogil on 10/19/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailFooterTableViewCell.h"
#import "FirebaseManager.h"

@interface ActionDetailFooterTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *remindMeButton;
@property (weak, nonatomic) IBOutlet UIButton *actionCompletedButton;

@end

@implementation ActionDetailFooterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.remindMeButton setTitle:@"Remind me later..." forState:UIControlStateNormal];
    self.remindMeButton.backgroundColor = [UIColor voicesBlue];
    self.remindMeButton.tintColor = [UIColor whiteColor];
    self.remindMeButton.clipsToBounds = YES;
    self.remindMeButton.layer.cornerRadius = kButtonCornerRadius;
    self.remindMeButton.titleLabel.font = [UIFont voicesFontWithSize:15];
    
    [self.actionCompletedButton setTitle:@"Mark Completed" forState:UIControlStateNormal];
    self.actionCompletedButton.backgroundColor = [UIColor voicesBlue];
    self.actionCompletedButton.tintColor = [UIColor whiteColor];
    self.actionCompletedButton.clipsToBounds = YES;
    self.actionCompletedButton.layer.cornerRadius = kButtonCornerRadius;
    self.actionCompletedButton.titleLabel.font = [UIFont voicesFontWithSize:15];
}

- (IBAction)remindMeButtonDidPress:(id)sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"presentActionReminderViewController" object:nil];
}

- (IBAction)actionCompletedButtonDidPress:(id)sender {
    
    [[FirebaseManager sharedInstance] actionCompleteButtonPressed:self.action];

    if (self.action.isCompleted) {
        self.action.isCompleted = NO;
        self.actionCompletedButton.tintColor = [UIColor voicesLightGray];
    }
    else {
        self.action.isCompleted = YES;
        self.actionCompletedButton.tintColor = [UIColor voicesGreen];

//        [self.delegate presentThankYouAlertForGroup:self.group andAction:self.action];

        if ([VoicesUtilities isInDebugMode]) {
            return;
        }
        else {
//            [FIRAnalytics logEventWithName:@"userCompletedAction"
//                                parameters:@{ @"actionKey": self.action.key}];
        }
    }
}

@end
