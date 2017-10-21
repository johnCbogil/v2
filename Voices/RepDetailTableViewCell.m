
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
    
    self.contactTypeImageView.tintColor = [UIColor voicesOrange];
    self.cardView.layer.cornerRadius = kButtonCornerRadius;
    self.cardView.clipsToBounds = YES;
}

@end
