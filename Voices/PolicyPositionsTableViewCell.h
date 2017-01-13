//
//  PolicyPositionsTableViewCell.h
//  Voices
//
//  Created by perrin cloutier on 1/6/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PolicyPositionsDelegate.h"

@interface PolicyPositionsTableViewCell : UITableViewCell <UITableViewDataSource,UITableViewDelegate,PolicyPositionsDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic)NSMutableArray *listOfPolicyPositions;
@property (nonatomic,weak)id<PolicyPositionsDelegate>policyPositionsDelegate;
- (void)configureCellWithPolicyPositions:(NSMutableArray *)listOfPolicyPositions;


@end

