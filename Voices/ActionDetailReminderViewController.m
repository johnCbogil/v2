//
//  ActionDetailReminderViewController.m
//  Voices
//
//  Created by John Bogil on 10/19/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailReminderViewController.h"
#import "VoicesUtilities.h"
@import UserNotifications;

// TODO: CREATE FIREBASE ANALYTIC EVENT

@interface ActionDetailReminderViewController () <UNUserNotificationCenterDelegate>

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation ActionDetailReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.instructionLabel.text = @"When would you like to be reminded about this action?";
    self.instructionLabel.numberOfLines = 0;
    self.instructionLabel.font = [UIFont voicesFontWithSize:23];
    
    [self.submitButton setTitle:@"Set Reminder" forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = [UIFont voicesFontWithSize:25];
    self.submitButton.backgroundColor = [UIColor voicesBlue];
    self.submitButton.tintColor = [UIColor whiteColor];
    self.submitButton.layer.cornerRadius = kButtonCornerRadius;
    self.submitButton.clipsToBounds = YES;
    
    self.datePicker.minimumDate = [NSDate date];
}

- (IBAction)submitButtonDidPress:(id)sender {
    
    if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        
        [self askForNotificationAuth];
    }
    else {
        
        [self scheduleNotification];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)askForNotificationAuth {
    
    NSString *notificationMessage = @"Pleaes turn on notifications so we can remind you.";
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:notificationMessage
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *button0 = [UIAlertAction
                              actionWithTitle:@"Maybe later"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {}];
    
    UIAlertAction *button1 = [UIAlertAction
                              actionWithTitle:@"Yes"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
                                  UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
                                  [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                                  [[UIApplication sharedApplication] registerForRemoteNotifications];
                                  
                                  [self scheduleNotification];
                              }];
    
    [alert addAction:button0];
    [alert addAction:button1];
    [self presentViewController:alert animated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)scheduleNotification {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center removeAllDeliveredNotifications];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear +
                                                                             NSCalendarUnitMonth + NSCalendarUnitDay +
                                                                             NSCalendarUnitHour + NSCalendarUnitMinute +
                                                                             NSCalendarUnitSecond)
                                                                   fromDate:self.datePicker.date];
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    content.title = @"Your voice matters.";
    content.body = @"This is your friendlty action reminder";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"localNoti" content:content trigger:trigger];

    [center addNotificationRequest:request withCompletionHandler:nil];
}

@end
