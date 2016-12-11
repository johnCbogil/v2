//
//  ReportingManager.h
//  Voices
//
//  Created by John Bogil on 12/10/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportingManager : NSObject

+ (ReportingManager *) sharedInstance;
- (void)reportEvent:(NSString *)eventType eventFocus:(NSString *)eventFocus eventData:(NSString *)eventData;
@end
