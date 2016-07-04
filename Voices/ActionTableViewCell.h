//
//  ActionTableViewCell.h
//  Voices
//
//  Created by John Bogil on 4/19/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Action.h"

@interface ActionTableViewCell : UITableViewCell

- (void)initWithAction:(Action *)action;


@end