//
//  RepTableViewCell.h
//  v3
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RepTableViewCell;
@protocol RepTableViewCellDelegate
- (void)repTableViewCellDidTapEmailButton:(RepTableViewCell *) cell;
@end

@interface RepTableViewCell : UITableViewCell
- (void)initWithRep:(id)rep;
@property (weak, nonatomic) id <RepTableViewCellDelegate> delegate;

@end

