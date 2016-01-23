//
//  RepresentativesViewController.m
//  Voices
//
//  Created by Bogil, John on 1/22/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepresentativesViewController.h"
#import "CongresspersonTableViewCell.h"
#import "StateRepTableViewCell.h"
#import "RepManager.h"
#import "LocationService.h"
#import "CacheManager.h"

@interface RepresentativesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIView *zeroStateContainer;
@end

@implementation RepresentativesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addObservers];
    [self checkLocationAuthorizationStatus];
    [self createRefreshControl];
    if (self.index == 0) {
        self.title = @"Congress";
        [[CacheManager sharedInstance] checkCacheForRepresentative:@"cachedCongresspersons"];
        [self.tableView registerNib:[UINib nibWithNibName:@"CongresspersonTableViewCell" bundle:nil]forCellReuseIdentifier:@"CongresspersonTableViewCell"];
    }
    else {
        self.title = @"State Legislators";
        [[CacheManager sharedInstance] checkCacheForRepresentative:@"cachedStateLegislators"];
        [self.tableView registerNib:[UINib nibWithNibName:@"StateRepTableViewCell" bundle:nil]forCellReuseIdentifier:@"StateRepTableViewCell"];

    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(turnZeroStateOn) name:@"turnZeroStateOn" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(turnZeroStateOff) name:@"turnZeroStateOff" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endRefreshing) name:@"endRefreshing" object:nil];
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTableView) name:@"reloadData" object:nil];
}

- (void)dealloc {
    [[LocationService sharedInstance]removeObserver:self forKeyPath:@"currentLocation" context:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - UI Methods

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
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateCurrentLocation) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.index == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[RepManager sharedInstance].listOfCongressmen] forKey:@"cachedCongresspersons"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[RepManager sharedInstance].listofStateLegislators] forKey:@"cachedStateLegislators"];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.index == 0) {
        return [RepManager sharedInstance].listOfCongressmen.count;
    }
    else {
        return [RepManager sharedInstance].listofStateLegislators.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.index == 0) {
        CongresspersonTableViewCell *cell = (CongresspersonTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CongresspersonTableViewCell" forIndexPath:indexPath];
        [cell initFromIndexPath:indexPath];
        return cell;
    }
    else {
        StateRepTableViewCell *cell = (StateRepTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"StateRepTableViewCell" forIndexPath:indexPath];
        [cell initFromIndexPath:indexPath];
        return cell;
    }
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        if (self.index == 0) {
            [self getRepresentativesForCurrentLocation];
        }
        else {
            [self getRepresentativesForCurrentLocation];
        }
        [self.refreshControl endRefreshing];
    }
}

- (void)getRepresentativesForCurrentLocation {
    if (self.index == 0) {
        [[RepManager sharedInstance]createCongressmenFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } onError:^(NSError *error) {
            NSLog(@"error");
        }];
    }
    else {
        [[RepManager sharedInstance]createStateLegislatorsFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } onError:^(NSError *error) {
            NSLog(@"error");
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}
@end