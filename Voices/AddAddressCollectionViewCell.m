//
//  AddAddressCollectionViewCell.m
//  Voices
//
//  Created by John Bogil on 5/6/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "AddAddressCollectionViewCell.h"

@implementation AddAddressCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.addAddressLabel.font = [UIFont voicesFontWithSize:25];
    self.emojiLabel.font = [UIFont voicesFontWithSize:60];
    self.privacyLabel.font = [UIFont voicesFontWithSize:12];
    self.addAddressButton.tintColor = [UIColor whiteColor];
    self.addAddressButton.backgroundColor = [UIColor voicesOrange];
    self.addAddressButton.layer.cornerRadius = kButtonCornerRadius + 10;
    self.addAddressButton.titleLabel.font = [UIFont voicesFontWithSize:24];
}

- (IBAction)addAddressButtonDidPress:(id)sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"presentSearchViewController" object:nil];
}

@end
