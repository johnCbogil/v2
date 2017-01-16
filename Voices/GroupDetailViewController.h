//
//  GroupDetailViewController.h
//  Voices
//
//  Created by John Bogil on 7/5/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "ExpandingCellDelegate.h"
 
@interface GroupDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,ExpandingCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Group *group;


@end
