//
//  GroupDescriptionTableViewCell.m
//  Voices
//
//  Created by perrin cloutier on 1/6/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "GroupDescriptionTableViewCell.h"

@interface GroupDescriptionTableViewCell ()

@property (nonatomic)BOOL isExpanded;
@property (strong, nonatomic) IBOutlet UIButton *expandButton;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;

@end

@implementation GroupDescriptionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - set up textview

- (void)configureTextViewWithContents:(NSString *)contents {
    self.textView.text = contents;
    self.textView.font = [UIFont voicesFontWithSize:21];
    self.textView.textColor = [UIColor blackColor];
    self.textView.scrollsToTop = true;
    [self.textView setTextContainerInset:UIEdgeInsetsMake(8, 2, 8, 2)];
    [self.textView setShowsVerticalScrollIndicator:false];
    [self.textView setUserInteractionEnabled:false];
    [self.textView setScrollEnabled:false];
    [self.textView setContentOffset:CGPointZero animated:YES];
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
    [self.arrowImage setImage:[UIImage imageNamed:@"collapseArrow"]];
 }

- (void)contractTextView {
    self.isExpanded = false;
    [self maxLines];
    [self.arrowImage setImage:[UIImage imageNamed:@"expandArrow"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end
