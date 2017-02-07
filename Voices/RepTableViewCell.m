//
//  RepTableViewCell.h
//  Voices
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "RepTableViewCell.h"
#import "AFHTTPRequestOperation.h"
#import "ReportingManager.h"
#import "Representative.h"
#import "ScriptManager.h"
#import "UIImageView+AFNetworking.h"

#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <MessageUI/MFMailComposeViewController.h>

@import FirebaseAnalytics;
@import UserNotifications;

@interface RepTableViewCell() <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) Representative *representative;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
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
    self.tweetButton.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.callButton.tintColor = [UIColor voicesOrange];
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
        
        // TODO: ADD FADE HERE
        [UIView animateWithDuration:.25 animations:^{
            self.photo.image = image;
        }];
        
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
            [[ReportingManager sharedInstance] reportEvent:kCALL_EVENT eventFocus:self.representative.fullName eventData:[ScriptManager sharedInstance].lastAction.key];
            NSURL* callUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.representative.phone]];
            if ([[UIApplication sharedApplication] canOpenURL:callUrl]) {
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
    
    if (self.representative.bioguide.length > 0) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:kRepContactFormsJSON ofType:@"json"];
        NSData *contactFormsJSON = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:nil];
        NSDictionary *contactFormsDict = [NSJSONSerialization JSONObjectWithData:contactFormsJSON options:NSJSONReadingAllowFragments error:nil];
        
        NSURL *contactFormURL = [NSURL URLWithString:[contactFormsDict valueForKey:self.representative.bioguide]];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"presentWebView" object:contactFormURL];
    }
    else if (self.representative.email.length > 0) {
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
    NSLog(@"Notification : %@", notification);
    NSString *callInfo = [[notification userInfo] objectForKey:@"callState"];
    if ([callInfo isEqualToString: CTCallStateDialing]) {
        //The call state, before connection is established, when the user initiates the call.
        NSLog(@"****** call is dialing ******");
        [self scheduleNotification];
    }
    if ([callInfo isEqualToString: CTCallStateIncoming]) {
        //The call state, before connection is established, when a call is incoming but not yet answered by the user.
        NSLog(@"***** call is incoming ******");
    }
    if ([callInfo isEqualToString: CTCallStateConnected]) {
        //The call state when the call is fully established for all parties involved.
        [[ReportingManager sharedInstance] reportEvent:kCALL_EVENT eventFocus:self.representative.fullName eventData:[ScriptManager sharedInstance].lastAction.key];
        NSLog(@"***** call connected *****");
    }
    if ([callInfo isEqualToString: CTCallStateDisconnected]) {
        //the call state has ended
        NSLog(@"***** call ended *****");
    }
}

#pragma mark - UNNotifications

- (void)scheduleNotification {
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
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //center.delegate = self;
    [center removeAllDeliveredNotifications];
    [center addNotificationRequest:request withCompletionHandler:nil];
}

@end
