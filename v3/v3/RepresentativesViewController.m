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
@property (weak, nonatomic) IBOutlet UILabel *screenNumberLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation RepresentativesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.index == 0) {
        // check if theres congressmen in the cache
        [[CacheManager sharedInstance] checkCacheForRepresentative:@"cachedCongresspersons"];

        [self.tableView registerNib:[UINib nibWithNibName:@"CongresspersonTableViewCell" bundle:nil]forCellReuseIdentifier:@"CongresspersonTableViewCell"];
    }
    else {
        [[CacheManager sharedInstance] checkCacheForRepresentative:@"cachedStateLegislators"];
        [self.tableView registerNib:[UINib nibWithNibName:@"StateRepTableViewCell" bundle:nil]forCellReuseIdentifier:@"StateRepTableViewCell"];

    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.screenNumberLabel.text = [NSString stringWithFormat:@"%lu", self.index];
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)dealloc {
    [[LocationService sharedInstance]removeObserver:self forKeyPath:@"currentLocation" context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        if (self.index == 0) {
            [self getCongresspersonForCurrentLocation];
        }
        else {
            [self getStateLegislatorsForCurrentLocation];
        }
//        [self.refreshControl endRefreshing];
    }
}

- (void)getCongresspersonForCurrentLocation {
    [[RepManager sharedInstance]createCongressmenFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } onError:^(NSError *error) {
        NSLog(@"error");
    }];
}

- (void)getStateLegislatorsForCurrentLocation {
    [[RepManager sharedInstance]createStateLegislatorsFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } onError:^(NSError *error) {
        NSLog(@"error");
    }];
}
@end