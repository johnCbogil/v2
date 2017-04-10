//
//  ActionDetailTopTableViewCell.h
//  Voices
//
//  Created by John Bogil on 3/26/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Action.h"
#import "Group.h"

@interface ActionDetailTopTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *groupImageButton;
@property (weak, nonatomic) IBOutlet UILabel *actionTitleLabel;
- (void)initWithAction:(Action *)action andGroup:(Group *)group;

@end
