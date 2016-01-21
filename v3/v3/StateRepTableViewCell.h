//
//  StateRepTableViewCell.h
//  v3
//
//  Created by John Bogil on 10/16/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertDelegate.h"

@interface StateRepTableViewCell : UITableViewCell

@property (strong, nonatomic) id <CustomAlertDelegate> delegate;
- (void)initFromIndexPath:(NSIndexPath*)indexPath;

@end