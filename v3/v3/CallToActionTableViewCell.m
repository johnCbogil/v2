//
//  CallToActionTableViewCell.m
//  Voices
//
//  Created by John Bogil on 4/19/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "CallToActionTableViewCell.h"

@interface CallToActionTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *ctaGroupName;
@property (weak, nonatomic) IBOutlet UILabel *ctaDescription;

@end

@implementation CallToActionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.ctaDescription.numberOfLines = 0;
    self.ctaGroupName.numberOfLines = 0;
    [self.ctaGroupName sizeToFit];
    [self.ctaDescription sizeToFit];
}

- (void)initWithData:(NSDictionary *)data {
    self.ctaGroupName.text = [data valueForKey:@"advocacyGroupName"];
    self.ctaDescription.text = [data valueForKey:@"body"];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
