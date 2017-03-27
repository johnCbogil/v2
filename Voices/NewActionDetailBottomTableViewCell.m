//
//  NewActionDetailBottomTableViewCell.m
//  Voices
//
//  Created by John Bogil on 3/26/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailBottomTableViewCell.h"

@implementation NewActionDetailBottomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.descriptionTextView.backgroundColor = [UIColor redColor];
 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
