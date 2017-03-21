//
//  NewActionDetailViewController.m
//  Voices
//
//  Created by John Bogil on 3/20/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailViewController.h"
#import "NewActionDetailTableViewCell.h"
#import "LocationService.h"
#import "RepsManager.h"

@interface NewActionDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation NewActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview registerNib:[UINib nibWithNibName:@"NewActionDetailTableViewCell" bundle:nil]forCellReuseIdentifier:@"NewActionDetailTableViewCell"];
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    
    [[LocationService sharedInstance]getCoordinatesFromSearchText:homeAddress withCompletion:^(CLLocation *locationResults) {
        
        [[RepsManager sharedInstance]createFederalRepresentativesFromLocation:locationResults WithCompletion:^{
            NSLog(@"%@", locationResults);
            [self.tableview reloadData];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
        
        [[RepsManager sharedInstance]createStateRepresentativesFromLocation:locationResults WithCompletion:^{
            [self.tableview reloadData];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
        
        [[RepsManager sharedInstance]createNYCRepsFromLocation:locationResults];
        
    } onError:^(NSError *googleMapsError) {
        NSLog(@"%@", [googleMapsError localizedDescription]);
    }];

}

#pragma mark - UITableView Delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewActionDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewActionDetailTableViewCell"];
    [cell initWithGroup:self.group andAction:self.action];
//    cell.repsArray = [[RepsManager sharedInstance]fetchRepsForIndex:self.action.level];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 1000;
}
@end
