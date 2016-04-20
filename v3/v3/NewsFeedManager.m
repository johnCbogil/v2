//
//  NewsFeedManager.m
//  Voices
//
//  Created by John Bogil on 4/19/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NewsFeedManager.h"

@implementation NewsFeedManager


+(NewsFeedManager *) sharedInstance {
    static NewsFeedManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.newsFeedObjects = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)createCallToActionFromNotificationPayload:(NSDictionary *)notificationPayload {
    NSDictionary *callToActionDict = @{@"advocacyGroupName":[notificationPayload valueForKey:@""],
                                   @"advocacyGroupLogoURL" : [notificationPayload valueForKey:@""],
                                   @"ctaTimestamp" : [notificationPayload valueForKey:@""],
                                   @"ctaTitle" : [notificationPayload valueForKey:@""],
                                   @"ctaBody" : [notificationPayload valueForKey:@""]
                                   };
    
    [self.newsFeedObjects addObject:callToActionDict];
}
// WHAT OBJECTS WILL THE CTA OBJECT NEED TO CONTAIN?
// Name of advocacy group
// Logo of advocacy group
// Date the CTA was sent/recieved (?)
// Title of message
// Talking points
// MAX SIZE IS 2 - 4KB !


//     NSString *title = [[[notificationPayload valueForKey:@"aps"]valueForKey:@"alert"]valueForKey:@"title"];
//NSString *body = [[[notificationPayload valueForKey:@"aps"]valueForKey:@"alert"]valueForKey:@"body"];
//        NSString *fullMessage = [notificationPayload valueForKey:@"fullMessage"];
//        NSArray *talkingPointsArray = [notificationPayload valueForKey:@"talkingPoints"];
//
//        NSString *alertViewText = [NSString stringWithFormat:@"%@\n\n● %@\n\n● %@\n\n● %@\n", fullMessage, talkingPointsArray[0], talkingPointsArray[1], talkingPointsArray[2]];

// UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:alertViewText  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
// [alert show];

@end
