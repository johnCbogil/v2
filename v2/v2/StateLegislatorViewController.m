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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [RepManager sharedInstance].listofStateLegislators.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        StateLegislator *stateLegislator = [RepManager sharedInstance].listofStateLegislators[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", stateLegislator.firstName, stateLegislator.lastName];
        if (stateLegislator.photo) {
            cell.imageView.image = stateLegislator.photo;
        }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
