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

@class NewActionDetailTopTableViewCell;

@protocol ExpandActionDescriptionDelegate <NSObject>   //define delegate protocol

- (void)expandActionDescription:(NewActionDetailTopTableViewCell *)sender;

@end

@interface NewActionDetailTopTableViewCell : UITableViewCell

- (void)initWithAction:(Action *)action andGroup:(Group *)group;
@property (strong, nonatomic) id <ExpandActionDescriptionDelegate> delegate;

@end
