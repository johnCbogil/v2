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
    
    self.openCloseMenuItemImageView.tintColor = [UIColor orangeColor];
    self.openCloseMenuItemImageView.backgroundColor = [UIColor clearColor];
    
    self.textView.scrollEnabled = NO;
    self.textView.font = [UIFont voicesFontWithSize:19];
}

@end
