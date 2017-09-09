//
//  ActionDetailMenuItemTableViewCell.h
//  Voices
//
//  Created by Bogil, John on 7/11/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface ActionDetailMenuItemTableViewCell : UITableViewCell <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *itemTitle;
@property (weak, nonatomic) IBOutlet UIImageView *openCloseMenuItemImageView;

@end
