//
//  ExpandingCellDelegate.h
//  Voices
//
//  Created by perrin cloutier on 1/6/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GroupDescriptionTableViewCell;

@protocol ExpandingCellDelegate <NSObject>

@required

- (void)expandButtonDidPress:(GroupDescriptionTableViewCell *)cell;

@optional

- (void)maxLines;
- (void)configureTextViewWithContents:(NSString *)contents;
- (void)expandTextView;
- (void)contractTextView;

@end
