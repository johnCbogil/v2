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
    self.textView.text = contents;
    self.fontSize = 21;
    self.font = [UIFont voicesFontWithSize:self.fontSize];
//    [self getTextViewLineCountWithContents:contents];
    self.textView.font = self.font;
    self.textView.textColor = [UIColor blackColor];
    self.textView.scrollsToTop = true;
    [self.textView setShowsVerticalScrollIndicator:true];
//    [self.textView setScrollEnabled:false];
//    [self.textView setEditable:false];
//    [self.textView setSelectable:false];
    self.textView.textContainer.maximumNumberOfLines = 3;
    [self.textView sizeToFit];
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
        self.textView.textContainer.maximumNumberOfLines = self.totalLines;
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

#pragma mark - Expanding Cell delegate methods

- (IBAction)expandButtonDidPress:(GroupDescriptionTableViewCell *)cell
{
    if(self.isExpanded == false){
        [self expandTextView];        
     }
    else{
        [self contractTextView];
    }
    [self.expandingCellDelegate expandButtonDidPress:self];
}

- (void)expandTextView
{
    self.textView.textContainer.maximumNumberOfLines = 0;

    self.isExpanded = true;
    [self.expandButton setTitle:@"...less" forState:UIControlStateNormal];
//    [self.expandButton setBackgroundColor:[UIColor clearColor]];
}

- (void)contractTextView
{
    self.isExpanded = false;
    [self.expandButton setTitle:@"...more" forState:UIControlStateNormal];
//    [self.expandButton setBackgroundColor:[UIColor whiteColor]];
 }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end
