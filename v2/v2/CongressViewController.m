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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableData)
                                                 name:@"reloadTableView"
                                               object:nil];
    
    
    [[LocationService sharedInstance] startUpdatingLocation];
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)reloadTableData{
    [self.tableView reloadData];
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


 #pragma mark - Navigation
 
//  In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//  Get the new view controller using [segue destinationViewController].
//  Pass the selected object to the new view controller.
     
     
 }

@end
