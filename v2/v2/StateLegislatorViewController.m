//
//  StateLegislatorViewController.m
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//
#import "StateLegislatorViewController.h"
#import "StateLegislator.h"
#import "RepManager.h"
#import "LocationService.h"
#import "StateRepTableViewCell.h"
@interface StateLegislatorViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation StateLegislatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"State Legislators";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self populateStateLegislatorsFromLocation:[LocationService sharedInstance].currentLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadStateLegislatorTableData)
                                                 name:@"reloadStateLegislatorTableView"
                                               object:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StateRepTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"StateRepTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

#pragma mark - UITableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [RepManager sharedInstance].listofStateLegislators.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//        StateLegislator *stateLegislator = [RepManager sharedInstance].listofStateLegislators[indexPath.row];
//        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", stateLegislator.firstName, stateLegislator.lastName];
//        if (stateLegislator.photo) {
//            cell.imageView.image = [UIImage imageWithData:stateLegislator.photo];
//        }
//    return cell;
    
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
@end