//
//  RepsCollectionViewCell.m
//  Voices
//
//  Created by John Bogil on 11/12/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepsCollectionViewCell.h"
#import "RepTableViewCell.h"
#import "EmptyRepTableViewCell.h"
#import "RepManager.h"

@interface RepsCollectionViewCell()

@property (strong, nonatomic) NSArray *tableViewDataSource;
@property (strong, nonatomic) EmptyRepTableViewCell *emptyRepTableViewCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RepsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor redColor];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:kRepTableViewCell bundle:nil]forCellReuseIdentifier:kRepTableViewCell];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection = NO;
 
    self.tableViewDataSource = [[RepManager sharedInstance]createRepsForIndex:self.index];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.tableViewDataSource.count > 0){
        return self.tableViewDataSource.count;
    } else{
        return 1;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell;
    if(self.tableViewDataSource.count > 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:kRepTableViewCell];
        
        [cell initWithRep:self.tableViewDataSource[indexPath.row]];
    }
    else {
        UITableViewCell *emptyStateCell = [[UITableViewCell alloc]init];
        emptyStateCell.backgroundView = self.emptyRepTableViewCell;
        cell = emptyStateCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableViewDataSource.count > 0) {
        return 140;
    }
    else {
        return 400;
    }
}

@end
