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

@protocol RefreshHeaderCellDelegate <NSObject>

- (void)refreshHeaderCell;

@end

@interface ActionTableViewCell : UITableViewCell

@property (strong, nonatomic) id <PresentThankYouAlertDelegate> delegate;
@property (strong, nonatomic) id <RefreshHeaderCellDelegate> refreshDelegate;
@property (weak, nonatomic) IBOutlet UIButton *takeActionButton;
- (void)initWithGroup:(Group *)group andAction:(Action *)action;


@end
