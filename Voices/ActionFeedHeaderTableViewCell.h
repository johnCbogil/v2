//
//  ActionFeedHeaderTableViewCell.h
//  Voices
//
//  Created by Bogil, John on 7/30/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ActionFeedHeaderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *totalActionsCompletedLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (void)refreshTotalActionsCompleted;

@end
