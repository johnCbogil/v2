//
//  RepTableViewCell.h
//  Voices
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "RepTableViewCell.h"
#import "AFHTTPRequestOperation.h"
#import "ContactsView.h"
#import "ReportingManager.h"
#import "Representative.h"
#import "ScriptManager.h"
#import "UIImageView+AFNetworking.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <MessageUI/MFMailComposeViewController.h>

@import UserNotifications;

@interface RepTableViewCell() <MFMailComposeViewControllerDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) Representative *representative;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet ContactsView *contactsView;
@property (nonatomic) CTCallCenter *callCenter;

@end

@implementation RepTableViewCell

#pragma mark - Lifecycle events

- (void)awakeFromNib {
    [super awakeFromNib];
    self.photo.backgroundColor = [UIColor clearColor];
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = 5;
    self.photo.clipsToBounds = YES;
    [self setupFont];
    [self registerCallStateNotification];
}

- (void)initWithRep:(id)rep {
    self.representative = rep;
    NSString *title = self.representative.shortTitle ? self.representative.shortTitle : self.representative.title;
    self.name.text = [NSString stringWithFormat:@"%@ %@ %@", title, self.representative.firstName, self.representative.lastName];
    [self.contactsView configureWithRepresentative:self.representative];
    [self setupImage];
}

#pragma mark - Helper methods

- (void)setupFont {
    self.name.font = self.name.text.length > 15 ? [UIFont voicesFontWithSize:26] : [UIFont voicesFontWithSize:28];
    self.name.textColor = [UIColor voicesBlack];
}

- (void)setupImage {
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
        
        self.photo.alpha = 0;
        [UIView animateWithDuration:.25 animations:^{
            self.photo.image = image;
            self.photo.alpha = 1.0;
        }];
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
    }];
}


// TODO: THIS PROB SHOULDNT BE HAPPENING HERE AND ITS BEING REPEATED
#pragma mark - NSNotifications

-(void)registerCallStateNotification {
    //Register for notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callStateDidChange:) name:@"CTCallStateDidChange" object:nil];
    
    //Instantiate call center
    CTCallCenter *callCenter = [[CTCallCenter alloc] init];
    self.callCenter = callCenter;
    
    self.callCenter.callEventHandler = ^(CTCall* call) {
        
        //Announce that we've had a state change in CallCenter
        NSDictionary *dict = [NSDictionary dictionaryWithObject:call.callState forKey:@"callState"]; [[NSNotificationCenter defaultCenter] postNotificationName:@"CTCallStateDidChange" object:nil userInfo:dict];
    };
}

- (void)callStateDidChange:(NSNotification *)notification {
    //Log the notification
    NSString *callInfo = [[notification userInfo] objectForKey:@"callState"];
    if ([callInfo isEqualToString: CTCallStateDialing]) {
        //The call state, before connection is established, when the user initiates the call.
        [self scheduleNotification];
    }
    if ([callInfo isEqualToString: CTCallStateIncoming]) {
        //The call state, before connection is established, when a call is incoming but not yet answered by the user.
    }
    if ([callInfo isEqualToString: CTCallStateConnected]) {
        //The call state when the call is fully established for all parties involved.
    }
    if ([callInfo isEqualToString: CTCallStateDisconnected]) {
        //the call state has ended
    }
}

#pragma mark - UNNotifications

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
    content.body = [ScriptManager sharedInstance].lastAction.script.length ? [ScriptManager sharedInstance].lastAction.script : kGenericScript;
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"localNoti" content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:nil];
}

@end
