//
//  ActionDetailReminderViewController.m
//  Voices
//
//  Created by John Bogil on 10/19/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailReminderViewController.h"
@import UserNotifications;

@interface ActionDetailReminderViewController () <UNUserNotificationCenterDelegate>

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation ActionDetailReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.instructionLabel.text = @"When would you like to be reminded about this action?";
    self.instructionLabel.numberOfLines = 0;
    [self.submitButton setTitle:@"Set Reminder" forState:UIControlStateNormal];
}

- (IBAction)submitButtonDidPress:(id)sender {
    
    NSLog(@"%@", self.datePicker.date);
}


- (void)scheduleNotification {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center removeAllDeliveredNotifications];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:1.f];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear +
                                                                             NSCalendarUnitMonth + NSCalendarUnitDay +
                                                                             NSCalendarUnitHour + NSCalendarUnitMinute +
                                                                             NSCalendarUnitSecond)
                                                                   fromDate:date];
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    content.title = @"Swipe down for full message";
//    content.body = [ScriptManager sharedInstance].lastAction.script.length ? [ScriptManager sharedInstance].lastAction.script : kGenericScript;
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"localNoti" content:content trigger:trigger];

    [center addNotificationRequest:request withCompletionHandler:nil];
}


@end
