//
//  ActionFeedHeaderTableViewCell.m
//  Voices
//
//  Created by Bogil, John on 7/30/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionFeedHeaderTableViewCell.h"
#import "FirebaseManager.h"
#import "CurrentUser.h"

@implementation ActionFeedHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.totalActionsCompletedLabel.backgroundColor = [UIColor voicesGreen];
    self.totalActionsCompletedLabel.layer.cornerRadius = 10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshTotalActionsCompleted {
    
    [[FirebaseManager sharedInstance]fetchListOfCompletedActionsWithCompletion:^(NSArray *listOfCompletedActions) {
        self.totalActionsCompletedLabel.text = [NSString stringWithFormat:@"%ld", listOfCompletedActions.count];
    } onError:^(NSError *error) {
        
    }];
}
@end
