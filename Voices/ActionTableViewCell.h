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

@protocol PresentThankYouAlertDelegate <NSObject>

- (void)presentThankYouAlertForGroup:(Group *)group andAction:(Action *)action;

@end

@interface ActionTableViewCell : UITableViewCell

@property (strong, nonatomic) id <PresentThankYouAlertDelegate> delegate;
- (void)initWithGroup:(Group *)group andAction:(Action *)action;

@end
