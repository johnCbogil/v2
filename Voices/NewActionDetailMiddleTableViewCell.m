//
//  NewActionDetailMiddleTableViewCell.m
//  Voices
//
//  Created by John Bogil on 3/26/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailMiddleTableViewCell.h"

@implementation NewActionDetailMiddleTableViewCell

// TODO: BUTTONS NEED TO KNOW WHO THE SELECTED REP IS

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.callButton.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.tweetButton.tintColor = [UIColor voicesOrange];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)callButtonDidPress:(id)sender {
}

- (IBAction)emailButtonDidPress:(id)sender {
}

- (IBAction)tweetButtonDidPress:(id)sender {
}

@end