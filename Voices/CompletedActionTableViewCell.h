//
//  CompletedActionTableViewCell.h
//  Voices
//
//  Created by John Bogil on 10/11/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompletedAction.h"

@interface CompletedActionTableViewCell : UITableViewCell

- (void)initWithData:(CompletedAction *)completedAction;

@end
