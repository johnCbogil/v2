//
//  StateLegislatorViewController.m
//  v3
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//
#import "StateLegislatorViewController.h"
#import "StateLegislator.h"
#import "RepManager.h"
#import "LocationService.h"
#import "StateRepTableViewCell.h"
#import "UIFont+voicesFont.h"
#import "CacheManager.h"
#import "CustomAlertDelegate.h"
#import <STPopup/STPopup.h>

@implementation StateLegislatorViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self addObservers];
    [self checkLocationAuthorizationStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[CacheManager sharedInstance]checkCacheForRepresentative:@"cachedStateLegislators"];
    self.title = @"State Legislators";
    [self createRefreshControl];
    [self.tableView registerNib:[UINib nibWithNibName:@"StateRepTableViewCell" bundle:nil]forCellReuseIdentifier:@"StateRepTableViewCell"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    @try{
        [[LocationService sharedInstance]removeObserver:self forKeyPath:@"currentLocation" context:nil];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
 }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)checkLocationAuthorizationStatus {
    if ([CLLocationManager authorizationStatus] <= 2) {
        [self turnZeroStateOn];
    }
    else {
        [self turnZeroStateOff];
    }
}

#pragma mark - UI Controls

- (void)createRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

- (void)addObservers {
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStateLegislatorTableData)name:@"reloadStateLegislatorTableView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefreshing) name:@"endRefreshing" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(turnZeroStateOn) name:@"turnZeroStateOn" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(turnZeroStateOff) name:@"turnZeroStateOff" object:nil];
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

#pragma mark - Request Data methods

- (void)pullToRefresh {
    if ([CLLocationManager authorizationStatus] <= 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"Turn on location services to see who represents your current location" delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil, nil];
        [alert show];
        [self.refreshControl endRefreshing];
    }
    else {
        [[LocationService sharedInstance] startUpdatingLocation];
        [[RepManager sharedInstance]createStateLegislatorsFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            });
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
    }
}
- (void)populateStateLegislatorsFromLocation:(CLLocation*)location {
    [[RepManager sharedInstance]createStateLegislatorsFromLocation:location WithCompletion:^{
        [UIView animateWithDuration:.25 animations:^{
            [self turnZeroStateOff];
            self.tableView.alpha = 1.0;
        }];
        [self.tableView reloadData];
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}

- (void)reloadStateLegislatorTableData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        if ([RepManager sharedInstance].listofStateLegislators.count > 0) {
            // do nothing
        }
        else {
            [self populateStateLegislatorsFromLocation:[LocationService sharedInstance].currentLocation]; 
        }
    }
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[RepManager sharedInstance].listofStateLegislators] forKey:@"cachedStateLegislators"];
    return [RepManager sharedInstance].listofStateLegislators.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StateRepTableViewCell *cell = (StateRepTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"StateRepTableViewCell" forIndexPath:indexPath];
    [cell initFromIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}
@end