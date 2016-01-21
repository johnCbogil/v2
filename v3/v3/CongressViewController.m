//
//  ViewController.m
//  v3
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//
#import "CongressViewController.h"
#import "LocationService.h"
#import "RepManager.h"
#import "Congressperson.h"
#import "StateLegislator.h"
#import "CacheManager.h"
#import "UIFont+voicesFont.h"
#import "CongresspersonTableViewCell.h"
#import <STPopup/STPopup.h>

@implementation CongressViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self addObservers];
    [self checkLocationAuthorizationStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[CacheManager sharedInstance]checkCacheForRepresentative:@"cachedCongresspersons"];
    self.title = @"Congress";
    [self createRefreshControl];
    [self.tableView registerNib:[UINib nibWithNibName:@"CongresspersonTableViewCell" bundle:nil]forCellReuseIdentifier:@"CongresspersonTableViewCell"];
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

#pragma mark - UI Controls

- (void)createRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)checkLocationAuthorizationStatus {
    if ([CLLocationManager authorizationStatus] <= 2) {
        [self turnZeroStateOn];
    }
    else {
        [self turnZeroStateOff];
    }
}


- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(turnZeroStateOn) name:@"turnZeroStateOn" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(turnZeroStateOff) name:@"turnZeroStateOff" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCongressTableData) name:@"reloadCongressTableView" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endRefreshing) name:@"endRefreshing" object:nil];
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
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


#pragma mark - Request Data Methods

- (void)pullToRefresh {
    if ([CLLocationManager authorizationStatus] <= 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"Turn on location services to see who represents your current location" delegate:nil cancelButtonTitle:@"Alright" otherButtonTitles:nil, nil];
        [alert show];
        [self.refreshControl endRefreshing];
    }
    else {
        [[LocationService sharedInstance] startUpdatingLocation];
        //        [[RepManager sharedInstance]createCongressmenFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                [self.tableView reloadData];
        //                [self.refreshControl endRefreshing];
        //            });
        //        } onError:^(NSError *error) {
        //            [error localizedDescription];
        //        }];
    }
}

- (void)populateCongressmenFromLocation:(CLLocation*)location {
    [[RepManager sharedInstance]createCongressmenFromLocation:location WithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.25 animations:^{
                self.tableView.alpha = 1.0;
            }];
            [self.tableView reloadData];
        });
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}

- (void)reloadCongressTableData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        //        if (![RepManager sharedInstance].listOfCongressmen.count > 0) {
        [self populateCongressmenFromLocation:[LocationService sharedInstance].currentLocation];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        
        //    }
    }
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[RepManager sharedInstance].listOfCongressmen] forKey:@"cachedCongresspersons"];
    return [RepManager sharedInstance].listOfCongressmen.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CongresspersonTableViewCell *cell = (CongresspersonTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CongresspersonTableViewCell" forIndexPath:indexPath];
    [cell initFromIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}
@end