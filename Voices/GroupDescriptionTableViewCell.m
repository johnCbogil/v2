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
@property (nonatomic)NSUInteger totalLines;
@property (nonatomic)NSUInteger lineLimit;
@property (nonatomic)CGFloat buttonHeightInset;
@property (nonatomic)CGFloat buttonWidth;
@property (nonatomic)CGFloat buttonHeight;
@property (nonatomic)CGFloat buttonXPosition;
@property (nonatomic)CGFloat buttonYPosition;

@end

@implementation GroupDescriptionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - set up textview

- (void)configureTextViewWithContents:(NSString *)contents
{
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.textView setFrame:frame];
    [self getTextViewLineCountWithContents:contents];
    // Does not allow for font size > 17 due to magic number values in the button size
    self.textView.font = [UIFont voicesFontWithSize:16];
    self.textView.textColor = [UIColor blackColor];
    self.textView.scrollsToTop = true;
    self.textView.scrollEnabled = false;
    [self.textView setEditable:false];
    [self.textView setSelectable:false];
    [self.textView sizeToFit];
    if(self.totalLines > self.lineLimit){
        if(self.expandButton == nil){
            self.expandButton = [self makeExpandButton];
        }
        [self positionButton];
    }
}

- (void)getTextViewLineCountWithContents:(NSString *)contents
{
    self.textView.text = contents; // text passed from viewcontroller
    self.lineLimit = 3.0;
    if(!self.totalLines){        // total lines of the full text
        self.totalLines = [self getTotalNumberOfLines];
    }
    if(self.isExpanded == false){
        self.textView.textContainer.maximumNumberOfLines = self.lineLimit;
    }
    else{
        self.textView.textContainer.maximumNumberOfLines = self.totalLines +1;
    }
}

- (NSUInteger)getTotalNumberOfLines
{
    NSLayoutManager *layoutManager = [self.textView layoutManager];
    NSUInteger totalNumberOfLines, index, numberOfGlyphs =
    [layoutManager numberOfGlyphs];
    NSRange lineRange;
    for (totalNumberOfLines = 0, index = 0; index < numberOfGlyphs; totalNumberOfLines++){
        (void) [layoutManager lineFragmentRectForGlyphAtIndex:index
                                               effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
    }
    return totalNumberOfLines;
}
       
#pragma mark - expand button methods
       
- (UIButton *)makeExpandButton
{
    UIButton *expandButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [expandButton setTitle:@"...more" forState:UIControlStateNormal];
    [expandButton setBackgroundColor:[UIColor whiteColor]];
    [expandButton setTitleColor:[UIColor voicesOrange] forState:UIControlStateNormal];
    [expandButton showsTouchWhenHighlighted];
    [expandButton addTarget:self action:@selector(expandButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    expandButton.titleLabel.font = [UIFont voicesFontWithSize:16];
    [expandButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    self.buttonHeightInset = 13.0;
    self.buttonWidth = 55.0;    // Positions button at the end of the textview text
    self.buttonHeight = 20.0;
    self.buttonXPosition = self.textView.frame.size.width - self.buttonWidth;
    return expandButton;
}

- (void)positionButton
{
    // Repositions button Y axis only
    self.buttonYPosition = self.textView.frame.size.height - self.buttonHeight - self.buttonHeightInset;
    [self.expandButton setFrame:CGRectMake(self.buttonXPosition, self.buttonYPosition, self.buttonWidth, self.buttonHeight + self.buttonHeightInset)];
    [self.textView addSubview:self.expandButton];
}

#pragma mark - Expanding Cell delegate methods

- (void)expandButtonDidPress:(GroupDescriptionTableViewCell *)cell
{
    if(self.isExpanded == false){
        [self expandTextView];
    }
    else{
        [self contractTextView];
    }
    [self positionButton];
    [self.expandingCellDelegate expandButtonDidPress:self];
}


- (void)expandTextView
{
    self.isExpanded = true;
    [self.expandButton setTitle:@"" forState:UIControlStateNormal];
    [self.expandButton setBackgroundColor:[UIColor clearColor]];
}

- (void)contractTextView
{
    self.isExpanded = false;
    [self.expandButton setTitle:@"...more" forState:UIControlStateNormal];
    [self.expandButton setBackgroundColor:[UIColor whiteColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end
