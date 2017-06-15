//
//  NewActionDetailEmptyRepTableViewCell.m
//  Voices
//
//  Created by Bogil, John on 6/13/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailEmptyRepTableViewCell.h"
#import "VoicesUtilities.h"

@interface NewActionDetailEmptyRepTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *addAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *emojiLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyLabel;
@property (weak, nonatomic) IBOutlet UIButton *addAddressButton;

@end

@implementation NewActionDetailEmptyRepTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.addAddressLabel.font = [UIFont voicesFontWithSize:17];
    self.emojiLabel.font = [UIFont voicesFontWithSize:60];
    self.privacyLabel.font = [UIFont voicesFontWithSize:12];
    self.addAddressButton.tintColor = [UIColor whiteColor];
    self.addAddressButton.backgroundColor = [UIColor voicesOrange];
    self.addAddressButton.layer.cornerRadius = kButtonCornerRadius + 10;
    self.emojiLabel.text = [NSString stringWithFormat:@"%@ %@", [VoicesUtilities getRandomEmojiMale], [VoicesUtilities getRandomEmojiFemale]];
    self.addAddressButton.titleLabel.font = [UIFont voicesFontWithSize:24];
}

- (IBAction)addAddressButtonDidPress:(id)sender {

    [[NSNotificationCenter defaultCenter]postNotificationName:@"presentSearchViewController" object:nil];
}

@end
