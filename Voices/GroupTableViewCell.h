//
//  GroupTableViewCell.h
//  Voices
//
//  Created by John Bogil on 4/17/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Group;

@interface GroupTableViewCell : UITableViewCell

- (void)initWithGroup:(Group *)group;

@end
