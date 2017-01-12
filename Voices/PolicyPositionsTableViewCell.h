//
//  PolicyPositionsTableViewCell.h
//  Voices
//
//  Created by perrin cloutier on 1/6/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PolicyPositionsTableViewCell;

@protocol PolicyPositionsDelegate <NSObject>

@required

- (void)presentPolicyDetailViewController:(NSIndexPath *)indexPath;

@end


@interface PolicyPositionsTableViewCell : UITableViewCell <UITableViewDataSource,UITableViewDelegate,PolicyPositionsDelegate>

@property (nonatomic)UITableView *tableView;
@property (nonatomic)NSMutableArray *listOfPolicyPositions;
@property (nonatomic,weak)id<PolicyPositionsDelegate>policyPositionsDelegate;


@end

