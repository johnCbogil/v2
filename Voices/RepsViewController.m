//
//  RepsViewController.m
//  Voices
//
//  Created by Bogil, John on 1/22/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepsViewController.h"
#import "RepTableViewCell.h"
#import "RepManager.h"
#import "LocationService.h"
#import "NetworkManager.h"
#import "FBShimmeringView.h"
#import "FBShimmeringLayer.h"
#import "EmptyRepTableViewCell.h"
#import "RepDetailViewController.h"
 


@interface RepsViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *tableViewCellName;
@property (strong, nonatomic) NSArray *tableViewDataSource;
@property (strong, nonatomic) NSString *getRepresentativesMethod;
@property (weak, nonatomic) IBOutlet UILabel *zeroStateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *zeroStateImageOne;
@property (weak, nonatomic) IBOutlet UIImageView *zeroStateImageTwo;
@property (weak, nonatomic) IBOutlet UIView *zeroStateContainer;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringViewTwo;
@property (strong, nonatomic) EmptyRepTableViewCell *emptyRepTableViewCell;

@end

@implementation RepsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    [self configureTableView];
    [self createRefreshControl];
    [self createShimmer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self addObservers];
    [self toggleZeroState];
    [self reloadTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)fetchDataForIndex:(NSInteger)index {
    self.tableViewDataSource = [[RepManager sharedInstance]createRepsForIndex:index];
}

- (void)reloadDataSource:(NSInteger)index {
    if (self.index == 0) {
        self.tableViewDataSource = [RepManager sharedInstance].listOfFederalRepresentatives;
    }
    else if (self.index == 1) {
        self.tableViewDataSource = [RepManager sharedInstance].listOfStateRepresentatives;
    }
    else if (self.index == 2) {
        self.tableViewDataSource = [RepManager sharedInstance].listOfNYCRepresentatives;
    }
    
    [self toggleZeroState];
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)toggleZeroState {
    if (self.tableViewDataSource.count == 0) {
        [self turnZeroStateOn];
    }
    else {
        [self turnZeroStateOff];
    }
}

- (void)pullToRefresh {
    [[RepManager sharedInstance]startUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSearchText" object:nil];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endRefreshing) name:@"endRefreshing" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTableView) name:@"reloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingOperationDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidSuspendNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidCompleteNotification object:nil];
}

#pragma mark - UI Methods

- (void)configureTableView {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:kRepTableViewCell bundle:nil]forCellReuseIdentifier:kRepTableViewCell];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection = NO;
    
    // TODO: NOT SURE THIS SHOULD HAPPEN HERE
    self.emptyRepTableViewCell = [[EmptyRepTableViewCell alloc]init];
}

- (void)turnZeroStateOn {
    [UIView animateWithDuration:.25 animations:^{
        self.tableView.backgroundView.alpha = 1;
    }];
    if (self.index == 2 && [RepManager sharedInstance].listOfFederalRepresentatives.count > 0) {
        [self.emptyRepTableViewCell updateLabels:kLocalRepsMissing bottom:@""];
        [self.emptyRepTableViewCell updateImage];
    }
}

- (void)turnZeroStateOff {
    [UIView animateWithDuration:.25 animations:^{
        self.tableView.backgroundView.alpha = 0;
    }];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

- (void)reloadTableView {
    [self reloadDataSource:self.index];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)createRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

#pragma mark - Shimmer

- (void)createShimmer {
    //    self.zeroStateImageOne.frame = self.shimmeringView.bounds;
    //    self.shimmeringView.contentView = self.zeroStateImageOne;
    //    self.zeroStateImageTwo.frame = self.shimmeringViewTwo.bounds;
    //    self.shimmeringViewTwo.contentView = self.zeroStateImageTwo;
}

- (void)toggleShimmerOn {
    self.shimmeringView.shimmering = YES;
    self.shimmeringViewTwo.shimmering = YES;
}

- (void)toggleShimmerOff {
    self.shimmeringView.shimmering = NO;
    self.shimmeringViewTwo.shimmering = NO;
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    RepresentativeDetailViewController *repDetailViewController = [[RepresentativeDetailViewController alloc]init];
//    repDetailViewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"repDetailView"];
//    repDetailViewController.representative = self.tableViewDataSource[indexPath.row];
//    [self.navigationController pushViewController:repDetailViewController animated:YES];
//}



@end
