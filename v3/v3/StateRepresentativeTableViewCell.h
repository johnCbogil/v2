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

// DONT THINK I NEED THIS
@property (strong, nonatomic) id <CustomAlertDelegate> delegate;
// THIS SHOULD BE INITWITHREP
- (void)initFromIndexPath:(NSIndexPath*)indexPath;

@end