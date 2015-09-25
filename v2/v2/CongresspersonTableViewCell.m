//
//  CongresspersonTableViewCell.m
//  v2
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "CongresspersonTableViewCell.h"

@implementation CongresspersonTableViewCell

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//
//
//    
//    return self;
//}
@end
