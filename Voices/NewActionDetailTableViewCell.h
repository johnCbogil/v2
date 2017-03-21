//
//  NewActionDetailTableViewCell.h
//  Voices
//
//  Created by John Bogil on 3/20/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "Action.h"

@interface NewActionDetailTableViewCell : UITableViewCell

- (void)initWithGroup:(Group *)group andAction:(Action *)action;

@end
