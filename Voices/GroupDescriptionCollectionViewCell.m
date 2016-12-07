//
//  GroupDescriptionCollectionViewCell.m
//  Voices
//
//  Created by perrin cloutier on 12/5/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "GroupDescriptionCollectionViewCell.h"


@interface GroupDescriptionCollectionViewCell()

@property (weak, nonatomic) IBOutlet UITextView *groupDescriptionTextView;

@end


@implementation GroupDescriptionCollectionViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    // Center text in text view
    [self.groupDescriptionTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
}


- (void)initWithGroup:(Group *)group {
    
    self.group = group;
    self.groupDescriptionTextView.text = self.group.groupDescription;
    [self.groupDescriptionTextView adjustsFontForContentSizeCategory];
    self.groupDescriptionTextView.contentInset = UIEdgeInsetsMake(-7.0,0.0,0,0.0);
    self.groupDescriptionTextView.font = [UIFont voicesFontWithSize:17];
    [self.groupDescriptionTextView setContentOffset:CGPointZero animated:NO];
 }


#pragma mark - KVO


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UITextView *gdTextView = object;
    CGFloat topCorrect = ([gdTextView bounds].size.height - [gdTextView contentSize].height * [gdTextView zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    [gdTextView setContentInset:UIEdgeInsetsMake(topCorrect,0,0,0)];
    self.groupDescriptionTextView = gdTextView;
}


-(void)dealloc {
    
    [self.groupDescriptionTextView removeObserver:self forKeyPath:@"contentSize"];
}




@end
