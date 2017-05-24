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
#import "RepDetailViewController.h"
#import "RepsManager.h"
#import "LocationService.h"

@interface RepsCollectionViewCell()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation RepsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureTableView];
    [self configureRefreshControl];
}

- (void)configureTableView {
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:kRepTableViewCell bundle:nil]forCellReuseIdentifier:kRepTableViewCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"EmptyRepTableViewCell" bundle:nil]forCellReuseIdentifier:@"EmptyRepTableViewCell"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // TODO: FLIP FLAG WHEN READY TO ADD REP DETAIL VIEWS
    self.tableView.allowsSelection = NO;
    
    [self.tableView addSubview:self.refreshControl];
}

- (void)configureRefreshControl {
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.bounds = CGRectMake(self.refreshControl.bounds.origin.x,
                                            15,
                                            self.refreshControl.bounds.size.width,
                                            self.refreshControl.bounds.size.height);
    
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableViewDataSource.count > 0){
        return self.tableViewDataSource.count;
    } else if (self.index == 2){
        return 1;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell;
    if(self.tableViewDataSource.count > 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:kRepTableViewCell];
        [cell initWithRep:self.tableViewDataSource[indexPath.row]];
    }
    else if (self.index == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyRepTableViewCell"];
    }
    
    [self.refreshControl endRefreshing];
    [self toggleZeroState];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *repsStoryboard = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    RepDetailViewController *repDetailVC = [repsStoryboard instantiateViewControllerWithIdentifier:@"RepDetailViewController"];
    repDetailVC.representative = self.tableViewDataSource[indexPath.row];
    [self.repDetailDelegate pushToDetailVC:repDetailVC];
}

- (void)reloadTableView {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)pullToRefresh {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSearchBarPullToRefresh" object:nil];
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        [[LocationService sharedInstance]startUpdatingLocation];
        
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentPullToRefreshAlert" object:nil];
    }
    
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

#pragma mark - ZeroState Logic

- (void)toggleZeroState {
    if (self.tableViewDataSource.count == 0) {
        [self turnZeroStateOn];
    }
    else {
        [self turnZeroStateOff];
    }
}

- (void)turnZeroStateOn {
    [UIView animateWithDuration:.25 animations:^{
        self.tableView.backgroundView.alpha = 1;
    }];
}

- (void)turnZeroStateOff {
    [UIView animateWithDuration:.25 animations:^{
        self.tableView.backgroundView.alpha = 0;
    }];
}

@end
