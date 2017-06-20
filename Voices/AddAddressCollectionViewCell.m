//
//  AddAddressCollectionViewCell.m
//  Voices
//
//  Created by John Bogil on 5/6/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "AddAddressCollectionViewCell.h"
#import "VoicesUtilities.h"

@implementation AddAddressCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.addAddressLabel.font = [UIFont voicesFontWithSize:25];
    self.emojiLabel.font = [UIFont voicesFontWithSize:60];
    self.privacyLabel.font = [UIFont voicesFontWithSize:12];
    self.addAddressButton.tintColor = [UIColor whiteColor];
    self.addAddressButton.backgroundColor = [UIColor voicesOrange];
    self.addAddressButton.layer.cornerRadius = kButtonCornerRadius + 10;
    self.emojiLabel.text = [NSString stringWithFormat:@"%@ %@", [VoicesUtilities getRandomEmojiMale], [VoicesUtilities getRandomEmojiFemale]];
    self.addAddressButton.titleLabel.font = [UIFont voicesFontWithSize:24];
    
    NSTimer* timer = [NSTimer timerWithTimeInterval:3.0f target:self selector:@selector(updateEmojiLabel) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (IBAction)addAddressButtonDidPress:(id)sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"presentSearchViewControllerInRootVC" object:nil];
}

- (void)updateEmojiLabel {

    self.emojiLabel.text = [NSString stringWithFormat:@"%@ %@", [VoicesUtilities getRandomEmojiMale], [VoicesUtilities getRandomEmojiFemale]];
}



@end
