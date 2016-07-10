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

@interface EmptyState()

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end

@implementation EmptyState

- (instancetype)initWithTopLabel:(NSString *)topLabel andBottomLabel:(NSString *)bottomLabel {
    self = [super init];
    
    UIView *emptyStateView = [[[NSBundle mainBundle] loadNibNamed:@"EmptyState" owner:self options:nil] objectAtIndex:0];
    
    emptyStateView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:emptyStateView];
    
    //Trailing
    NSLayoutConstraint *trailing =[NSLayoutConstraint
                                   constraintWithItem:emptyStateView
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.0f
                                   constant:0.f];
    
    //Leading
    
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:emptyStateView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];
    
    //Bottom
    NSLayoutConstraint *bottom =[NSLayoutConstraint
                                 constraintWithItem:emptyStateView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:1.0f
                                 constant:0.f];
    
    //Top
    NSLayoutConstraint *top =[NSLayoutConstraint
                                 constraintWithItem:emptyStateView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeTop
                                 multiplier:1.0f
                                 constant:0.f];
    
    
    [self addConstraint:trailing];
    [self addConstraint:bottom];
    [self addConstraint:top];
    [self addConstraint:leading];

    self.topLabel.text = topLabel;
    self.topLabel.font = [UIFont voicesFontWithSize:19];
    self.topLabel.textColor = [UIColor voicesBlack];
    
    self.bottomLabel.text = bottomLabel;
    self.bottomLabel.font = [UIFont voicesFontWithSize:17];
    self.bottomLabel.textColor = [UIColor voicesGray];
    
    
    return self;
}

@end
