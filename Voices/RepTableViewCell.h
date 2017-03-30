//
//  RepTableViewCell.h
//  v3
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepTableViewCell : UITableViewCell

@property(nonatomic)NSDictionary *repsContactForms;
- (void)initWithRep:(id)rep andRepsContactForms:(NSDictionary *)repsContactForms;

@end
