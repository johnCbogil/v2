//
//  GroupDetailTableViewCell.h
//  Voices
//
//  Created by perrin cloutier on 2/8/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowGroupDelegate.h"

@interface GroupDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *followGroupButton;
@property (weak, nonatomic)id<FollowGroupDelegate>followGroupDelegate;
- (IBAction)followGroupButtonDidPress:(id)sender;

@end
