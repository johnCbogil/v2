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

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
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
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableView"
                                                                    object:nil];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
        else {
            NSLog(@"need to implement search by name for states");
        }
        
    } onError:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}


@end
