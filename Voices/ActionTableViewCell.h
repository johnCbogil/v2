//
//  ActionTableViewCell.h
//  Voices
//
//  Created by John Bogil on 4/19/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Action.h"
#import "Group.h"

@interface ActionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *takeActionButton;
- (void)initWithGroup:(Group *)group andAction:(Action *)action;


@end
