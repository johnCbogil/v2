//
//  RepsCollectionViewCell.h
//  Voices
//
//  Created by John Bogil on 11/12/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepsCollectionViewCell : UICollectionViewCell <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic)NSInteger index;
@property (strong, nonatomic) NSArray *tableViewDataSource; // rename
- (void)reloadTableView;

@end