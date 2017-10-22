
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
    self.cardView.layer.cornerRadius = kButtonCornerRadius;
    self.cardView.layer.shadowOffset = CGSizeMake(-.2f, .2f);
    self.cardView.layer.shadowRadius = 1;
    self.cardView.layer.shadowOpacity = 0.2;
}

@end
