//
//  RepresentativesViewController.m
//  Voices
//
//  Created by Bogil, John on 1/22/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepresentativesViewController.h"
#import "FederalRepresentativeTableViewCell.h"
#import "StateRepresentativeTableViewCell.h"
#import "NYCRepresentativeTableViewCell.h"
#import "RepManager.h"
#import "LocationService.h"
#import "CacheManager.h"
#import "NetworkManager.h"
#import "VoicesConstants.h"

@interface RepresentativesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIView *zeroStateContainer;
@property (strong, nonatomic) NSString *tableViewCellName;
@property (strong, nonatomic) NSString *cachedRepresentatives;
@property (strong, nonatomic) NSArray *tableViewDataSource;
@property (strong, nonatomic) NSString *getRepresentativesMethod;
@end

@implementation RepresentativesViewController

- (void)viewWillAppear:(BOOL)animated {
    [self addObservers];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchDataForIndex:self.index];
    [self createTableView];
    [self checkLocationAuthorizationStatus];
    [self createRefreshControl];
}

- (void)fetchDataForIndex:(NSInteger)index {
    self.tableViewDataSource = [[RepManager sharedInstance]createRepsForIndex:index];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[LocationService sharedInstance]removeObserver:self forKeyPath:@"currentLocation" context:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(turnZeroStateOn) name:@"turnZeroStateOn" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(turnZeroStateOff) name:@"turnZeroStateOff" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endRefreshing) name:@"endRefreshing" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTableView) name:@"reloadData" object:nil];
//    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - UI Methods

- (void)createTableView {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:kFederalRepresentativeTableViewCell bundle:nil]forCellReuseIdentifier:kFederalRepresentativeTableViewCell];
    [self.tableView registerNib:[UINib nibWithNibName:kStateRepresentativeTableViewCell bundle:nil]forCellReuseIdentifier:kStateRepresentativeTableViewCell];
    [self.tableView registerNib:[UINib nibWithNibName:kNYCRepresentativeTableViewCell bundle:nil]forCellReuseIdentifier:kNYCRepresentativeTableViewCell];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)turnZeroStateOn {
    [UIView animateWithDuration:.25 animations:^{
        self.zeroStateContainer.alpha = 1;
    }];
}

- (void)turnZeroStateOff {
    [UIView animateWithDuration:.25 animations:^{
        self.zeroStateContainer.alpha = 0;
    }];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

- (void)reloadTableView {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)createRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateCurrentLocation) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewDataSource.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell;
    if (self.index == 0) {
         cell = [tableView dequeueReusableCellWithIdentifier:kFederalRepresentativeTableViewCell];
    }
    if (self.index == 1) {
         cell = [tableView dequeueReusableCellWithIdentifier:kStateRepresentativeTableViewCell];
    }
    if (self.index == 2) {
         cell = [tableView dequeueReusableCellWithIdentifier:kNYCRepresentativeTableViewCell];
    }

    [cell initWithRep:self.tableViewDataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

#pragma mark - LocationServices Methods

- (void)updateCurrentLocation {
    [[LocationService sharedInstance]startUpdatingLocation];
}

- (void)checkLocationAuthorizationStatus {
    if ([CLLocationManager authorizationStatus] <= 2) {
        [self turnZeroStateOn];
    }
    else {
        [self turnZeroStateOff];
    }
}




@end