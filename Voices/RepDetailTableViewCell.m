
//
//  RepDetailTableViewCell.m
//  Voices
//
//  Created by John Bogil on 10/21/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "RepDetailTableViewCell.h"

@interface RepDetailTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *cardView;

@end

@implementation RepDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureCardView];
    self.contactTypeImageView.tintColor = [UIColor voicesOrange];
    self.contactTypeImageView.backgroundColor = [UIColor whiteColor];
    self.contactInfoLabel.textColor = [UIColor voicesBlue];
    self.contactTypeLabel.textColor = [UIColor voicesBlue];
}

- (void)configureCardView {
    
    self.cardView.layer.cornerRadius = kButtonCornerRadius;
    self.cardView.clipsToBounds = YES;
    self.cardView.layer.masksToBounds = NO;
    self.cardView.layer.cornerRadius = 1; // if you like rounded corners
    self.cardView.layer.shadowOffset = CGSizeMake(-.2f, .2f); //%%% this shadow will hang slightly down and to the right
    self.cardView.layer.shadowRadius = 1; //%%% I prefer thinner, subtler shadows, but you can play with this
    self.cardView.layer.shadowOpacity = 0.2; //%%% same thing with this, subtle is better for me
    
    //%%% This is a little hard to explain, but basically, it lowers the performance required to build shadows.  If you don't use this, it will lag
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cardView.bounds];
    self.cardView.layer.shadowPath = path.CGPath;

}

@end
