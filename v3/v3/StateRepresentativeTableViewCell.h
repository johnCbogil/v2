//
//  StateRepresentativeTableViewCell.h
//  Voices
//
//  Created by John Bogil on 10/16/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertDelegate.h"

@interface StateRepresentativeTableViewCell : UITableViewCell

@property (strong, nonatomic) id <CustomAlertDelegate> delegate;
- (void)initFromIndexPath:(NSIndexPath*)indexPath;

@end