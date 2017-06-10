//
//  NewActionDetailTopTableViewCell.h
//  Voices
//
//  Created by John Bogil on 6/10/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Action.h"
#import "Group.h"

@interface NewActionDetailTopTableViewCell : UITableViewCell

- (void)initWithAction:(Action *)action andGroup:(Group *)group;

@end
