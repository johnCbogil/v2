//
//  AutocompleteViewController.m
//  Voices
//
//  Created by John Bogil on 2/16/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "AutocompleteViewController.h"

@import GooglePlaces;

@interface AutocompleteViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (strong, nonatomic) NSMutableArray *resultsArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AutocompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"Find Your Reps";
    _placesClient = [[GMSPlacesClient alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    self.resultsArray = @[].mutableCopy;

}

#pragma mark - Autocomplete methods ---------------------------------

- (void)placeAutocomplete:(NSString *)searchText {
    
//    self.resultsArray = nil;
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterAddress;
    
    [_placesClient autocompleteQuery:searchText
                              bounds:nil
                              filter:filter
                            callback:^(NSArray *results, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                    return;
                                }
                                
                                for (GMSAutocompletePrediction* result in results) {
                                    NSLog(@"Result '%@'", result.attributedFullText.string);
                                    [self.resultsArray addObject:result.attributedFullText];
                                    [self.tableView reloadData];
                                }
                            }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self placeAutocomplete:searchText];
}

#pragma mark - Tableview delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.attributedText = self.resultsArray[indexPath.row];
    return cell;
}

- (IBAction)currentLocationButtonDidPress:(id)sender {
}
@end
