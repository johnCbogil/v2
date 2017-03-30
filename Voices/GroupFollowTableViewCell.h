//
//  GroupFollowTableViewCell.m
//  Voices
//
//  Created by perrin cloutier on 2/13/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowGroupDelegate.h"

@interface GroupFollowTableViewCell : UITableViewCell

@property (nonatomic, weak)id<FollowGroupDelegate>followGroupDelegate;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *followGroupButton;
@property (weak, nonatomic) IBOutlet UITextView *groupWebsiteTextView;
- (IBAction)followGroupButtonDidPress:(id)sender;
- (void)setTitleForFollowGroupButton:(NSString *)title;

@end
