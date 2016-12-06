//
//  GroupDescriptionCollectionViewCell.m
//  Voices
//
//  Created by perrin cloutier on 12/5/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "GroupDescriptionCollectionViewCell.h"

@interface GroupDescriptionCollectionViewCell()

@property (weak, nonatomic) IBOutlet UITextView *groupDescriptionTextview;

@end

@implementation GroupDescriptionCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.groupDescriptionTextview.text = self.group.groupDescription;
    self.groupDescriptionTextview.contentInset = UIEdgeInsetsMake(-7.0,0.0,0,0.0);
     self.groupDescriptionTextview.font = [UIFont voicesFontWithSize:17];
    [self.groupDescriptionTextview setContentOffset:CGPointZero animated:NO];
}

@end
