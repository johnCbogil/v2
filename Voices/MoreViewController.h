//
//  MoreViewController.h
//  Voices
//
//  Created by Andy Wu on 3/15/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutViewController.h"
#import "IssueSurveyViewController.h"

@interface MoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) NSArray *choiceArray;
@property (nonatomic, strong) NSArray *subtitleArray;

@end
