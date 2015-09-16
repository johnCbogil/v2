//
//  HomeViewController.m
//  v2
//
//  Created by John Bogil on 8/7/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "HomeViewController.h"
#import "NetworkManager.h"
#import "LocationService.h"
#import "RepManager.h"
#import "CustomSearchBar.h"

@interface HomeViewController ()
@property (strong, nonatomic) IBOutlet CustomSearchBar *customSearchBarView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search by address";


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    for (id vc in self.childViewControllers) {
        if ([vc isKindOfClass:[UIPageViewController class]]) {
            self.pageVC = vc;
        }
    }
    [[LocationService sharedInstance]getCoordinatesFromSearchText:searchBar.text withCompletion:^(CLLocation *results) {
        if ([[self.pageVC.viewControllers[0]title] isEqualToString: @"Congress"]) {
            [[RepManager sharedInstance]createCongressmenFromLocation:results WithCompletion:^{
                NSLog(@"%@", results);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCongressTableView" object:nil];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
        else {
            [[LocationService sharedInstance]getCoordinatesFromSearchText:searchBar.text withCompletion:^(CLLocation *results) {
                [[RepManager sharedInstance]createStateLegislatorsFromLocation:results WithCompletion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadStateLegislatorTableView" object:nil];

                } onError:^(NSError *error) {
                    [error localizedDescription];
                }];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
    } onError:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}


@end