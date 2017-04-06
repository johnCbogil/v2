//
//  NewActionDetailMiddleTableViewCell.m
//  Voices
//
//  Created by John Bogil on 3/26/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailMiddleTableViewCell.h"

@implementation NewActionDetailMiddleTableViewCell

// TODO: HOOK UP ACTION BUTTONS

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.callButton.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.tweetButton.tintColor = [UIColor voicesOrange];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (IBAction)callButtonDidPress:(id)sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"presentCaller" object:nil];
}

- (IBAction)emailButtonDidPress:(id)sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"presentEmailComposer" object:nil];
}

- (IBAction)tweetButtonDidPress:(id)sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"presentTweetComposerInActionDetail" object:nil];
}

@end
