//
//  ActionDetailTopTableViewCellDelegate.h
//  Voices
//
//  Created by Andy Wu on 4/17/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

@class ActionDetailTopTableViewCell;

@protocol ActionDetailTopTableViewCellDelegate <NSObject>

@optional

- (void)delegateForCell:(ActionDetailTopTableViewCell *)cell;


@end
