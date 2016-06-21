//
//  ActionTableViewCell.m
//  Voices
//
//  Created by John Bogil on 4/19/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ActionTableViewCell.h"

@interface ActionTableViewCell()


@end

@implementation ActionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)initWithAction:(Action *)action {
    self.groupNameLabel.text = action.groupName;
    self.descriptionTextView.text = action.body;
    self.titleLabel.text = action.title;
    [self setmage:action.groupImageURL];
}

- (void)setmage:(NSString *)url {
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
