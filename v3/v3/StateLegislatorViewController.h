//
//  StateLegislatorViewController.h
//  v3
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StateLegislatorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIView *zeroStateContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end