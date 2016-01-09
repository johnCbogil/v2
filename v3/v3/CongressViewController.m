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
#import <STPopup/STPopup.h>
#import "UIFont+voicesFont.h"

@implementation CongressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkCache];
    self.title = @"Congress";
    [self addObservers];
    [self createRefreshControl];
    [self.tableView registerNib:[UINib nibWithNibName:@"CongresspersonTableViewCell" bundle:nil]forCellReuseIdentifier:@"CongresspersonTableViewCell"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleZeroStateLabel" object:nil];
}

- (void)checkCache {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingCachedCongresspersons = [currentDefaults objectForKey:@"cachedCongresspersons"];
    if (dataRepresentingCachedCongresspersons != nil) {
        NSArray *oldCachedCongresspersons = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingCachedCongresspersons];
        if (oldCachedCongresspersons != nil)
            [RepManager sharedInstance].listOfCongressmen = [[NSMutableArray alloc] initWithArray:oldCachedCongresspersons];
        self.tableView.alpha = 1.0;
        [self reloadCongressTableData];
    }
    else {
        [RepManager sharedInstance].listOfCongressmen = [[NSMutableArray alloc] init];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    @try{
        [[LocationService sharedInstance]removeObserver:self forKeyPath:@"currentLocation" context:nil];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}

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
    [[RepManager sharedInstance]createCongressmenFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
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
    //NSLog(@"%@", [[[RepManager sharedInstance].listOfCongressmen objectAtIndex:0]firstName]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
    
}
 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        [self populateCongressmenFromLocation:[LocationService sharedInstance].currentLocation];
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

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadCongressTableData)
                                                 name:@"reloadCongressTableView"
                                               object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endRefreshing) name:@"endRefreshing" object:nil];
    
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
}
@end