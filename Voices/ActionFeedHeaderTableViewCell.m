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

@interface ActionFeedHeaderTableViewCell()

@property (nonatomic) NSUInteger completedActionCountInt;

@end
@implementation ActionFeedHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self refreshTotalActionsCompleted];
    [self configureTotalActionsCompletedLabel];

    
    self.titleLabel.font = [UIFont voicesFontWithSize:19];
    self.subtitleLabel.font = [UIFont voicesFontWithSize:15];
    self.subtitleLabel.text = @"Select an action below to get started.";
}

- (void)refreshTotalActionsCompleted {
    
    [[FirebaseManager sharedInstance]fetchListOfCompletedActionsWithCompletion:^(NSArray *listOfCompletedActions) {
        
        self.completedActionCountInt = listOfCompletedActions.count;
        self.totalActionsCompletedLabel.text = [NSString stringWithFormat:@"%ld", self.completedActionCountInt];
        if (listOfCompletedActions.count > 0) {
            self.subtitleLabel.text = @"Keep up the good work!";
        }
        else {
            self.subtitleLabel.text = @"Select an action below to get started.";
        }
    } onError:^(NSError *error) {
        
    }];
}

- (void)configureTotalActionsCompletedLabel {
    
    self.totalActionsCompletedLabel.backgroundColor = [UIColor voicesGreen];
    self.totalActionsCompletedLabel.layer.cornerRadius = self.totalActionsCompletedLabel.bounds.size.width/2;
    self.totalActionsCompletedLabel.clipsToBounds = YES;
    self.totalActionsCompletedLabel.textColor = [UIColor whiteColor];
    self.totalActionsCompletedLabel.font = [UIFont voicesFontWithSize:22];
}
@end
