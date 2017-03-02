//
//  ResultsTableViewCell.m
//  Voices
//
//  Created by John Bogil on 2/23/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ResultsTableViewCell.h"

@implementation ResultsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.result.font = [UIFont voicesFontWithSize:17];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end