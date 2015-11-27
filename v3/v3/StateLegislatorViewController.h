//
//  StateLegislatorViewController.h
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewController.h"
#import "CustomAlertDelegate.h"
#import <STPopup/STPopup.h>
@interface StateLegislatorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CustomAlertDelegate>
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end