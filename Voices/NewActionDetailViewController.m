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
    
    [self configureTableview];
    [self fetchRepsForHomeAddress];
}

- (void)configureTableview {
    
    self.tableview.separatorColor = [UIColor clearColor];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview registerNib:[UINib nibWithNibName:@"NewActionDetailTableViewCell" bundle:nil]forCellReuseIdentifier:@"NewActionDetailTableViewCell"];
}

- (void)fetchRepsForHomeAddress {
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    [[LocationService sharedInstance]getCoordinatesFromSearchText:homeAddress withCompletion:^(CLLocation *locationResults) {
        
        if (self.action.level == 0) {
            [[RepsManager sharedInstance]createFederalRepresentativesFromLocation:locationResults WithCompletion:^{
                NSLog(@"%@", locationResults);
                [self.tableview reloadData];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
        else if (self.action.level == 1) {
            [[RepsManager sharedInstance]createStateRepresentativesFromLocation:locationResults WithCompletion:^{
                [self.tableview reloadData];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
        else if (self.action.level == 2) {
            [[RepsManager sharedInstance]createNYCRepsFromLocation:locationResults];
            [self.tableview reloadData];
        }
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
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 750;
}
@end
