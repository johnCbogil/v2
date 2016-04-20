//
//  NewsFeedManager.m
//  Voices
//
//  Created by John Bogil on 4/19/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NewsFeedManager.h"

@implementation NewsFeedManager

+ (NewsFeedManager *) sharedInstance {
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
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"newsFeedObjects"]) {
            self.newsFeedObjects = [[[NSUserDefaults standardUserDefaults]objectForKey:@"newsFeedObjects"]mutableCopy];
        }
        else {
            self.newsFeedObjects = [[NSMutableArray alloc]init];
        }
    }
    return self;
}

- (void)createCallToActionFromNotificationPayload:(NSDictionary *)notificationPayload {
    
    // THIS IS CRASHING ON LINE 35
//    NSLog(@"%@", notificationPayload);
//    NSString *name = [notificationPayload objectForKey:@"advocacyGroupName"];
//    NSDictionary *callToActionDict = @{@"advocacyGroupName": name,
//                                   @"advocacyGroupLogoURL" : [notificationPayload objectForKey:@"advocacyGroupLogoURL"],
//                                   @"ctaTimestamp" : [NSDate date], // NEED TO FORMAT THIS PROPERLY
//                                   @"body" : [notificationPayload objectForKey:@"body"]
//                                   };
    

    
    [self.newsFeedObjects addObject:notificationPayload];
    [[NSUserDefaults standardUserDefaults]setObject:self.newsFeedObjects forKey:@"newsFeedObjects"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
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
