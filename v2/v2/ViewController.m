//
//  ViewController.m
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "ViewController.h"
#import "LocationService.h"
#import "RepManager.h"
#import "Congressperson.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[LocationService sharedInstance] startUpdatingLocation];
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentLocation"]) {
        [[RepManager sharedInstance]determineCongressmen:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [RepManager sharedInstance].listOfCongressmen.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    Congressperson *congressperson =  [RepManager sharedInstance].listOfCongressmen[indexPath.row];
    cell.textLabel.text = congressperson.firstName;
    
    return cell;
}


@end
