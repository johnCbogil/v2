//
//  GroupFollowTableViewCell.m
//  Voices
//
//  Created by perrin cloutier on 2/13/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "GroupFollowTableViewCell.h"

@implementation GroupFollowTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    self.websiteButton.titleLabel.font = [UIFont voicesFontWithSize:19];
}

- (void)setTitleForFollowGroupButton:(NSString *)title {
    
    [self.followGroupButton setTitle:title forState:UIControlStateNormal];
}

- (IBAction)followGroupButtonDidPress:(id)sender {
    [self.followGroupDelegate followGroupButtonDidPress];
}

- (IBAction)websiteButtonDidPress:(id)sender {
    
    NSURL *url = [NSURL URLWithString:self.websiteButton.titleLabel.text];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"presentWebViewControllerForGroupDetail" object:url];
}

@end
