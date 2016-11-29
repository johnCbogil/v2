//
//  RepsCollectionViewCell.h
//  Voices
//
//  Created by John Bogil on 11/12/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepDetailViewController.h"

@protocol RepCellDelegate <NSObject>

-(void)pushToDetailVC: (RepDetailViewController*) repVC;

@end

@interface RepsCollectionViewCell : UICollectionViewCell <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id<RepCellDelegate> delegate;
@property (nonatomic)NSInteger index;
@property (strong, nonatomic) NSArray *tableViewDataSource; // rename
- (void)reloadTableView;

@end
