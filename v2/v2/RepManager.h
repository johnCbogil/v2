//
//  RepManager.h
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepManager : NSObject
+(RepManager *) sharedInstance;
@property (strong, nonatomic) NSArray *listOfCongressmen;
- (void)determineCongressmen:(void(^)(void))successBlock
                     onError:(void(^)(NSError *error))errorBlock;
@end
