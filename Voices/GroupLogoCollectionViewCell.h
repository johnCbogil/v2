//
//  GroupCollectionViewCell.h
//  Voices
//
//  Created by perrin cloutier on 12/5/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "UIImageView+AFNetworking.h"
#import "CurrentUser.h"
@import Firebase;


@class GroupLogoCollectionViewCell;

@protocol FollowGroupDelegate <NSObject>

- (IBAction)followGroupButtonDidPress:(GroupLogoCollectionViewCell *)cell;

@end


@interface GroupLogoCollectionViewCell : UICollectionViewCell<FollowGroupDelegate>

@property (weak, nonatomic) IBOutlet UIButton *followGroupButton;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSString *currentUserID;
@property (nonatomic, weak) id <FollowGroupDelegate> followGroupDelegate;
- (void)initWithGroup:(Group *)group;

@end
