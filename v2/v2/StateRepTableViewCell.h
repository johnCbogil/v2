//
//  StateRepTableViewCell.h
//  v2
//
//  Created by John Bogil on 10/16/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StateRepTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
- (void)initFromIndexPath:(NSIndexPath*)indexPath;
@end
