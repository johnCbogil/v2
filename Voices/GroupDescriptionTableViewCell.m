//
//  GroupDescriptionTableViewCell.m
//  Voices
//
//  Created by perrin cloutier on 1/6/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "GroupDescriptionTableViewCell.h"

@interface GroupDescriptionTableViewCell ()

@property (nonatomic)UIFont *font;
@property (nonatomic)int fontSize;
@property (nonatomic)BOOL isExpanded;

@end

@implementation GroupDescriptionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - set up textview

- (void)configureTextViewWithContents:(NSString *)contents {
    self.textView.text = contents;
    self.fontSize = 21;
    self.font = [UIFont voicesFontWithSize:self.fontSize];
    self.textView.font = self.font;
    self.textView.textColor = [UIColor blackColor];
    self.textView.scrollsToTop = true;
    [self.textView setShowsVerticalScrollIndicator:true];
    [self maxLines];
    [self.textView sizeToFit];
}

#pragma mark - Expanding Cell delegate methods

- (void)maxLines {
    if(self.isExpanded == false){
    self.textView.textContainer.maximumNumberOfLines = 3;
     }else{
         self.textView.textContainer.maximumNumberOfLines = 0;
     }
}

- (IBAction)expandButtonDidPress:(GroupDescriptionTableViewCell *)cell {
    if(self.isExpanded == false){
        [self expandTextView];
    }else{
        [self contractTextView];
    }
    [self.expandingCellDelegate expandButtonDidPress:self];
}

- (void)expandTextView {
    self.isExpanded = true;
    [self maxLines];
    [self.expandButton setTitle:@"       ⌃" forState:UIControlStateNormal];
}

- (void)contractTextView {
    self.isExpanded = false;
    [self maxLines];
    [self.expandButton setTitle:@"       ⌄" forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end
