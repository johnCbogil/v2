//
//  SearchViewController.m
//  Voices
//
//  Created by John Bogil on 3/2/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "SearchViewController.h"
#import "LocationService.h"
#import "RepsManager.h"
#import "ResultsTableViewCell.h"

@import GooglePlaces;

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (strong, nonatomic) NSString *homeAddress;
@property (strong, nonatomic) NSArray *resultsArray;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    self.title = @"Add Home Address";
    self.searchBar.placeholder = @"Enter address";
    self.searchBar.delegate  = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"ResultsTableViewCell" bundle:nil]forCellReuseIdentifier:@"ResultsTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"cell" bundle:nil]forCellReuseIdentifier:@"cell"];
    _placesClient = [[GMSPlacesClient alloc] init];
    self.resultsArray = @[];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [self placeAutocomplete:searchText];
    [self.tableView reloadData];
    
}

#pragma mark - Autocomplete methods ---------------------------------

- (void)placeAutocomplete:(NSString *)searchText {
    
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.country = @"US";
    
    [_placesClient autocompleteQuery:searchText
                              bounds:nil
                              filter:filter
                            callback:^(NSArray *results, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                    return;
                                }
                                NSMutableArray *tempArray = @[].mutableCopy;
                                for (GMSAutocompletePrediction* result in results) {
                                    NSLog(@"Result '%@'", result.attributedFullText.string);
                                    [tempArray addObject:result.attributedFullText.string];
                                }
                                self.resultsArray = tempArray;
                            }];
}

#pragma mark - Tableview delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.resultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont voicesFontWithSize:17];
    cell.textLabel.text = self.resultsArray[indexPath.row-1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
}



@end
