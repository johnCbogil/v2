//
//  InfluenceExplorer.h
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfluenceExplorer : NSObject
- (void)determineTopContributors:(NSString*)entityID;
- (void)determineTopIndustries:(NSString*)entityID;
- (void)idLookup:(NSString*)bioguideID;
@end