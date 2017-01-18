//
//  GroupDescriptionTableViewCell.h
//  Voices
//
//  Created by perrin cloutier on 1/6/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpandingCellDelegate.h"

@interface GroupDescriptionTableViewCell : UITableViewCell<ExpandingCellDelegate>

@property (strong, nonatomic)IBOutlet UITextView *textView;
@property (nonatomic, weak)id<ExpandingCellDelegate>expandingCellDelegate;
-(IBAction)expandButtonDidPress:(GroupDescriptionTableViewCell *)cell;
-(void)configureTextViewWithContents:(NSString *)contents;

@end
