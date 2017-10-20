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

    self.itemTitle.font = [UIFont voicesFontWithSize:19];
    self.itemTitle.numberOfLines = 0;
    self.itemTitle.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    
    self.openCloseMenuItemImageView.tintColor = [UIColor orangeColor];
    self.openCloseMenuItemImageView.backgroundColor = [UIColor clearColor];

}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"presentWebViewControllerForActionDetail" object:URL];
    return NO;
}

@end
