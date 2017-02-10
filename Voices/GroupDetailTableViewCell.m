//
//  GroupDetailTableViewCell.m
//  Voices
//
//  Created by perrin cloutier on 2/8/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "GroupDetailTableViewCell.h"

@interface GroupDetailTableViewCell()



@end

@implementation GroupDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self configureViews];
}

- (void)configureViews {
    self.followGroupButton.titleLabel.font = [UIFont voicesFontWithSize:23];
    self.followGroupButton.layer.cornerRadius = kButtonCornerRadius;
    self.groupImageView.backgroundColor = [UIColor clearColor];
    self.groupTypeLabel.font = [UIFont voicesFontWithSize:19];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)followGroupButtonDidPress:(GroupDetailTableViewCell *)cell {
    [self.followGroupDelegate followGroupButtonDidPress:self];
    [self.followGroupDelegate observeFollowStatus:self];
}

@end
