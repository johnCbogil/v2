//
//  InfluenceExplorerViewController.h
//  v2
//
//  Created by John Bogil on 7/28/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Congressperson.h"

@interface InfluenceExplorerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) Congressperson *congressperson;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
