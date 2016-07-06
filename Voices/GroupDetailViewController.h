//
//  GroupDetailViewController.h
//  Voices
//
//  Created by John Bogil on 7/5/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface GroupDetailViewController : UIViewController

@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSString *currentUserID;

@end
