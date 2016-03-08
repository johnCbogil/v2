//
//  FederalRepresentativeTableViewCell.h
//  v3
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertDelegate.h"

@interface FederalRepresentativeTableViewCell : UITableViewCell

- (void)initFromIndexPath:(NSIndexPath*)indexPath;
@property (strong, nonatomic) id <CustomAlertDelegate> delegate;

@end