//
//  MoreTableViewCell.m
//  Voices
//
//  Created by John Bogil on 9/30/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "MoreTableViewCell.h"

@implementation MoreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = [UIFont voicesBoldFontWithSize:20];
        self.subtitleLabel.font = [UIFont voicesFontWithSize:14];

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
