//
//  CompletedActionTableViewCell.m
//  Voices
//
//  Created by John Bogil on 10/11/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "CompletedActionTableViewCell.h"

@implementation CompletedActionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)initWithData:(CompletedAction *)completedAction {
    
    self.textLabel.text =  [NSString stringWithFormat:@"%ld", completedAction.timestamp];
    
}

@end
