//
//  NYCRepresentativeTableViewCell.m
//  Voices
//
//  Created by John Bogil on 1/24/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NYCRepresentativeTableViewCell.h"
#import "NYCRepresentative.h"
#import "RepManager.h"
#import "UIFont+voicesFont.h"
#import "UIColor+voicesOrange.h"

@interface NYCRepresentativeTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UILabel *districtNumberLabel;
@property (strong, nonatomic) NYCRepresentative *nycRepresentative;
@end

@implementation NYCRepresentativeTableViewCell

- (void)awakeFromNib {
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = 5;
    self.photo.clipsToBounds = YES;
    [self setFont];
    [self setColor];
}

- (void)setFont {
    
}

- (void)setColor {
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initFromIndexPath:(NSIndexPath*)indexPath {
    self.nycRepresentative =  [RepManager sharedInstance].listOfNYCRepresentatives[indexPath.row];
    self.nameLabel.text = self.nycRepresentative.name;

    
}

- (IBAction)emailButtonDidPress:(id)sender {
}

- (IBAction)callButtonDidPress:(id)sender {
}

@end
