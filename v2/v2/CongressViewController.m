//
//  ViewController.m
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "CongressViewController.h"
#import "LocationService.h"
#import "RepManager.h"
#import "Congressperson.h"
#import "StateLegislator.h"
@interface CongressViewController ()
@end

@implementation CongressViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadCongressTableData)
                                                 name:@"reloadCongressTableView"
                                               object:nil];
    
    
    [[LocationService sharedInstance] startUpdatingLocation];
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadCongressTableData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)reloadCongressTableData{
    // THIS LIST IS NOT BEING UPDATED UNTIL THE SECOND SEARCH CALL
    NSLog(@"%@", [[[RepManager sharedInstance].listOfCongressmen objectAtIndex:0]firstName]);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    [self.refreshControl endRefreshing];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        [self populateCongressmenFromLocation:[LocationService sharedInstance].currentLocation];

    }
}

- (void)populateCongressmenFromLocation:(CLLocation*)location {
    [[RepManager sharedInstance]createCongressmenFromLocation:location WithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
        });
    } onError:^(NSError *error) {
        [error localizedDescription];

    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [RepManager sharedInstance].listOfCongressmen.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Congressperson *congressperson =  [RepManager sharedInstance].listOfCongressmen[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", congressperson.firstName, congressperson.lastName];
    cell.detailTextLabel.text = congressperson.phone;
    cell.imageView.image = congressperson.photo;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // ADD AN ERROR BLOCK TO THIS
    [[RepManager sharedInstance]assignInfluenceExplorerID:[RepManager sharedInstance].listOfCongressmen[indexPath.row] withCompletion:^{
        
        // ADD AN ERROR BLOCK TO THIS
        [[RepManager sharedInstance]assignTopContributors:[RepManager sharedInstance].listOfCongressmen[indexPath.row] withCompletion:^{
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            self.influenceExplorerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"influenceExplorerViewController"];
            self.influenceExplorerVC.congressperson = [RepManager sharedInstance].listOfCongressmen[indexPath.row];
            [self.navigationController pushViewController:self.influenceExplorerVC animated:YES];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}
@end
