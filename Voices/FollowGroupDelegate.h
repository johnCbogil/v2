//
//  FollowGroupDelegate.h
//  Voices
//
//  Created by perrin cloutier on 2/13/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GroupDetailTableViewCell;

@protocol FollowGroupDelegate <NSObject>

@required

- (void)followGroupButtonDidPress;
- (void)observeFollowGroupStatus;
- (void)followGroupStatusDidChange;
@end
