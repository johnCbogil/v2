//
//  CongresspersonTableViewCell.h
//  v2
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CongresspersonTableViewCell;

@protocol CustomAlertDelegate <NSObject>
- (void)presentCustomAlertWithMessage:(NSString *)message andTitle:(NSString*)title;
@end

@interface CongresspersonTableViewCell : UITableViewCell
- (void)initFromIndexPath:(NSIndexPath*)indexPath;
// RENAME THIS DELEGATE TO BE MORE SPECIFIC
@property (strong, nonatomic) id <CustomAlertDelegate> delegate;

@end
