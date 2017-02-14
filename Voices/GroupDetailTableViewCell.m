//
//  GroupDetailTableViewCell.m
//  Voices
//
//  Created by perrin cloutier on 2/13/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "GroupDetailTableViewCell.h"

@implementation GroupDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self configureViews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureViews {
    self.followGroupButton.titleLabel.font = [UIFont voicesFontWithSize:23];
    self.followGroupButton.layer.cornerRadius = kButtonCornerRadius;
    self.groupImageView.backgroundColor = [UIColor clearColor];
    self.groupTypeLabel.font = [UIFont voicesFontWithSize:19];
}

- (void)setTitleForButton:(NSString *)title {
    [self.followGroupButton setTitle:title forState:UIControlStateNormal];
}

- (IBAction)followGroupButtonDidPress:(id)sender {
    [self.followGroupDelegate followGroupButtonDidPress];
    [self.followGroupDelegate followGroupStatusDidChange];
}

@end
