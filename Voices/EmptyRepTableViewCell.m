//
//  EmptyRepTableViewCell.m
//  Voices
//
//  Created by Bogil, John on 8/4/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "EmptyRepTableViewCell.h"
#import "VoicesUtilities.h"

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
    self.emojiLabel.text = [NSString stringWithFormat:@"🏡 %@", [VoicesUtilities getRandomEmoji]];
    
    NSTimer* timer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(updateEmojiLabel) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)updateEmojiLabel {
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.5;
    [self.emojiLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    self.emojiLabel.text = [NSString stringWithFormat:@"🏡 %@", [VoicesUtilities getRandomEmoji]];
}


@end
