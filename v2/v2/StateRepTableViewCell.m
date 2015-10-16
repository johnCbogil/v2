//
//  StateRepTableViewCell.m
//  v2
//
//  Created by John Bogil on 10/16/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "StateRepTableViewCell.h"
#import "RepManager.h"
#import "StateLegislator.h"
@interface StateRepTableViewCell ()
@property (strong, nonatomic) StateLegislator *stateLegislator;
@end
@implementation StateRepTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = self.photo.frame.size.width / 2;
    
    self.photo.clipsToBounds = YES;
    
    // ADD SHADOW
    self.shadowView.backgroundColor = [UIColor clearColor];
    self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeMake(0,2.5);
    self.shadowView.layer.shadowOpacity = 0.5;
    self.shadowView.layer.shadowRadius = 3.0;
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds cornerRadius:100.0].CGPath;
    [self.shadowView addSubview:self.photo];
}

- (void)initFromIndexPath:(NSIndexPath*)indexPath {
    self.stateLegislator =  [RepManager sharedInstance].listofStateLegislators[indexPath.row];
    self.name.text = [NSString stringWithFormat:@"%@ %@", self.stateLegislator.firstName, self.stateLegislator.lastName];
    self.photo.image = [UIImage imageWithData:self.stateLegislator.photo];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
@end