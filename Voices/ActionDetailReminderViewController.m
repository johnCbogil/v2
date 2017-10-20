//
//  ActionDetailReminderViewController.m
//  Voices
//
//  Created by John Bogil on 10/19/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailReminderViewController.h"

@interface ActionDetailReminderViewController ()

@end

@implementation ActionDetailReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//- (void)scheduleNotification {
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    center.delegate = self;
//    [center removeAllDeliveredNotifications];
//    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:1.f];
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear +
//                                                                             NSCalendarUnitMonth + NSCalendarUnitDay +
//                                                                             NSCalendarUnitHour + NSCalendarUnitMinute +
//                                                                             NSCalendarUnitSecond)
//                                                                   fromDate:date];
//    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
//    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
//    content.title = @"Swipe down for full message";
//    content.body = [ScriptManager sharedInstance].lastAction.script.length ? [ScriptManager sharedInstance].lastAction.script : kGenericScript;
//    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"localNoti" content:content trigger:trigger];
//    
//    [center addNotificationRequest:request withCompletionHandler:nil];
//}


@end
