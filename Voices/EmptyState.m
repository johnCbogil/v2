//
//  EmptyState.m
//  Voices
//
//  Created by John Bogil on 7/9/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "EmptyState.h"
#import "UIFont+voicesFont.h"
#import "UIColor+voicesColor.h"
#import "VoicesConstants.h"

@interface EmptyState()

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end

@implementation EmptyState

- (instancetype)init {
    self = [super init];
    
    self = [[[NSBundle mainBundle] loadNibNamed:@"EmptyState" owner:self options:nil] objectAtIndex:0];
    
    [self setFont];
    
    return self;
}

- (void)setFont {

    self.topLabel.text = kActionEmptyStateTopLabel;
    self.topLabel.font = [UIFont voicesFontWithSize:21];
    self.topLabel.textColor = [UIColor voicesBlack];
    
    self.bottomLabel.text = kActionEmptyStateBottomLabel;
    self.bottomLabel.font = [UIFont voicesFontWithSize:19];
    self.bottomLabel.textColor = [UIColor voicesGray];
}

- (void)updateLabels:(NSString *)top bottom:(NSString *)bottom  {

    self.topLabel.text = top;
    self.bottomLabel.text = bottom;
}

@end
