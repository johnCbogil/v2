//
//  CallToActionTableViewCell.m
//  Voices
//
//  Created by John Bogil on 4/19/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "CallToActionTableViewCell.h"

@interface CallToActionTableViewCell()


@end

@implementation CallToActionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)initWithData:(NSDictionary *)data {
    self.groupNameLabel.text = [data valueForKey:@"advocacyGroupName"];
    self.descriptionTextView.text = [data valueForKey:@"body"];
//    self.titleLabel.text = [data valueForKey:@""];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
