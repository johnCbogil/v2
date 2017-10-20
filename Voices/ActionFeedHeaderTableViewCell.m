//
//  ActionFeedHeaderTableViewCell.m
//  Voices
//
//  Created by Bogil, John on 7/30/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionFeedHeaderTableViewCell.h"

@interface ActionFeedHeaderTableViewCell()

@property (nonatomic) NSUInteger completedActionCountInt;

@end

@implementation ActionFeedHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self refreshTotalActionsCompleted:self.completedActionCountInt];
    [self configureTotalActionsCompletedLabel];

    self.titleLabel.text = @"Total Actions You Completed";
    self.titleLabel.font = [UIFont voicesFontWithSize:19];
    self.subtitleLabel.font = [UIFont voicesFontWithSize:15];
    self.subtitleLabel.text = @"Select an action below to get started.";
}

- (void)refreshTotalActionsCompleted:(NSUInteger)actionsCompletedCount {
    self.completedActionCountInt = actionsCompletedCount;
    self.totalActionsCompletedLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.completedActionCountInt];
    if (actionsCompletedCount > 0) {
        self.subtitleLabel.text = @"Thank you!";
    }
    else {
        self.subtitleLabel.text = @"Select an action below to get started.";
    }
}

- (void)configureTotalActionsCompletedLabel {
    
    self.totalActionsCompletedLabel.backgroundColor = [UIColor voicesGreen];
    self.totalActionsCompletedLabel.layer.cornerRadius = self.totalActionsCompletedLabel.bounds.size.width/2;
    self.totalActionsCompletedLabel.clipsToBounds = YES;
    self.totalActionsCompletedLabel.textColor = [UIColor whiteColor];
    self.totalActionsCompletedLabel.font = [UIFont voicesBoldFontWithSize:20];
    
}
@end
