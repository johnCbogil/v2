//
//  SearchViewController.m
//  Voices
//
//  Created by John Bogil on 3/2/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    self.title = @"Add Home Address";
    self.searchBar.placeholder = @"Enter address";
}


@end
