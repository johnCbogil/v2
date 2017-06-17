//
//  ActionDetailViewController.h
//  Voices
//
//  Created by John Bogil on 6/10/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "Action.h"

@interface ActionDetailViewController : UIViewController

@property (strong, nonatomic) Action *action;
@property (strong, nonatomic) Group *group;


@end
