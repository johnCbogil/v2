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

- (void)initWithCurrentUserID:(NSString *)currentUserID andGroup:(Group *)group andAction:(Action *)action;
@property (weak, nonatomic) IBOutlet UIButton *takeActionButton;


@end
