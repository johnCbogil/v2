//
//  RepsEmptyState.m
//  Voices
//
//  Created by Bogil, John on 8/4/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepsEmptyState.h"
#import "UIFont+voicesFont.h"
#import "UIColor+voicesColor.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@interface RepsEmptyState()

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIImageView *emptyStateImageView;

@end

@implementation RepsEmptyState

- (instancetype)init {
    self = [super init];
    
    self = [[[NSBundle mainBundle] loadNibNamed:@"RepsEmptyState" owner:self options:nil] objectAtIndex:0];
    
    [self setFont];
    
    return self;
}

- (void)setFont {
    
    self.topLabel.font = [UIFont voicesFontWithSize:21];
    self.bottomLabel.font = [UIFont voicesFontWithSize:19];
    
    CGAffineTransform rotateTransform = CGAffineTransformRotate(CGAffineTransformIdentity,
                                                                RADIANS(-15.0));
    
    self.emptyStateImageView.transform = rotateTransform;
}

- (void)updateLabels:(NSString *)top bottom:(NSString *)bottom  {

    self.topLabel.text = top;
    self.bottomLabel.text = bottom;
}

@end
