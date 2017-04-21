//
//  ActionDetailViewController.h
//  Voices
//
//  Created by John Bogil on 3/20/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "Action.h"
#import "ActionDetailTopTableViewCellDelegate.h"
#import "GroupDetailViewController.h"

@interface ActionDetailViewController : UIViewController <ActionDetailTopTableViewCellDelegate>

@property (strong, nonatomic) Action *action;
@property (strong, nonatomic) Group *group;

@end
