//
//  NewsFeedManager.h
//  Voices
//
//  Created by John Bogil on 4/19/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsFeedManager : NSObject

+ (NewsFeedManager *) sharedInstance;
- (void)createCallToActionFromNotificationPayload:(NSDictionary *)notificationPayload;

@property (strong, nonatomic) NSMutableArray *newsFeedObjects;

@end
