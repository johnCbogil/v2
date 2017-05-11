//
//  EmptyRepTableViewCell.m
//  Voices
//
//  Created by Bogil, John on 8/4/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "EmptyRepTableViewCell.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@interface EmptyRepTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *localRepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *emojiLabel;


@end

@implementation EmptyRepTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.localRepsLabel.font = [UIFont voicesFontWithSize:23];
    self.localRepsLabel.text = @"Local reps are not available in this area yet.";
    self.emojiLabel.font = [UIFont voicesFontWithSize:60];
    self.emojiLabel.text = @"👨‍💼👩‍💼";
    
}


@end
