//
//  ActionDetailMenuItemTableViewCell.m
//  Voices
//
//  Created by Bogil, John on 7/11/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailMenuItemTableViewCell.h"

@implementation ActionDetailMenuItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.itemTitle.font = [UIFont voicesFontWithSize:19];
    self.itemTitle.numberOfLines = 0;
}

@end
