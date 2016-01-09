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
@interface StateLegislatorViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation StateLegislatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkCache];
    self.title = @"State Legislators";
    [self addObservers];
    [self createRefreshControl];
    [[LocationService sharedInstance] startUpdatingLocation];
    [self.tableView registerNib:[UINib nibWithNibName:@"StateRepTableViewCell" bundle:nil]forCellReuseIdentifier:@"StateRepTableViewCell"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleZeroStateLabel" object:nil];
}

- (void)checkCache {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingCachedStateLegislators = [currentDefaults objectForKey:@"cachedStateLegislators"];
    if (dataRepresentingCachedStateLegislators != nil) {
        NSArray *oldCachedStateLegislators = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingCachedStateLegislators];
        if (oldCachedStateLegislators != nil)
            [RepManager sharedInstance].listofStateLegislators = [[NSMutableArray alloc] initWithArray:oldCachedStateLegislators];
        self.tableView.alpha = 1.0;
        [self reloadStateLegislatorTableData];
    }
    else {
        [RepManager sharedInstance].listofStateLegislators = [[NSMutableArray alloc] init];
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    @try{
        [[LocationService sharedInstance]removeObserver:self forKeyPath:@"currentLocation" context:nil];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)pullToRefresh {
    [[LocationService sharedInstance] startUpdatingLocation];
    [[RepManager sharedInstance]createStateLegislatorsFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}
- (void)populateStateLegislatorsFromLocation:(CLLocation*)location {
    [[RepManager sharedInstance]createStateLegislatorsFromLocation:location WithCompletion:^{
        [UIView animateWithDuration:.25 animations:^{
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
        [self populateStateLegislatorsFromLocation:[LocationService sharedInstance].currentLocation];
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
    return 100;
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

- (void)addObservers {
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadStateLegislatorTableData)
                                                 name:@"reloadStateLegislatorTableView"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefreshing) name:@"endRefreshing" object:nil];
}

@end