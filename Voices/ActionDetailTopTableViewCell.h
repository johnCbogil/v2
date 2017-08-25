//
//  ActionDetailTopTableViewCell.h
//  Voices
//
//  Created by John Bogil on 6/10/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Action.h"
#import "Group.h"

@class ActionDetailTopTableViewCell;

@protocol ExpandActionDescriptionDelegate <NSObject>   //define delegate protocol

- (void)expandActionDescription:(ActionDetailTopTableViewCell *)sender;

@end

@interface ActionDetailTopTableViewCell : UITableViewCell

- (void)initWithAction:(Action *)action andGroup:(Group *)group;
@property (strong, nonatomic) id <ExpandActionDescriptionDelegate> delegate;

@end
