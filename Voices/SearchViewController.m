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
@property (strong, nonatomic) NSArray *resultsArray;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    UIBarButtonItem *privacyButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"InfoButton"] style:UIBarButtonItemStylePlain target:self action:@selector(presentPrivacyAlert)];
    self.navigationItem.rightBarButtonItem = privacyButton;
    self.searchBar.placeholder = @"Enter address";
    self.searchBar.delegate  = self;
    [self.searchBar setReturnKeyType:UIReturnKeyDone];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"cell" bundle:nil]forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ResultsTableViewCell" bundle:nil]forCellReuseIdentifier:@"ResultsTableViewCell"];
    _placesClient = [[GMSPlacesClient alloc] init];
    self.resultsArray = @[];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.searchBar becomeFirstResponder];
}

- (void)presentPrivacyAlert {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Privacy is a human right"
                                message:@"Voices does not share your address with any third parties."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *button0 = [UIAlertAction
                              actionWithTitle:@"✊"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
    [alert addAction:button0];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveHomeAddress {
    
    [[NSUserDefaults standardUserDefaults]setObject:self.searchBar.text forKey:kHomeAddress];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length > 1) {
        [self placeAutocomplete:searchText onSuccess:^{
            [self.tableView reloadData];
        }];
    }
    else {
        self.resultsArray = @[];
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self saveHomeAddress];
}

#pragma mark - Autocomplete methods ---------------------------------

- (void)placeAutocomplete:(NSString *)searchText onSuccess:(void(^)(void))successBlock {
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.country = @"US";
    
    [_placesClient autocompleteQuery:searchText
                              bounds:nil
                              filter:filter
                            callback:^(NSArray *results, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"%@", [error localizedDescription]);
                                    return;
                                }
                                NSLog(@"%@", results);
                                NSMutableArray *tempArray = @[].mutableCopy;
                                for (GMSAutocompletePrediction* result in results) {
                                    [tempArray addObject:result.attributedFullText.string];
                                }
                                self.resultsArray = tempArray;
                                if (successBlock) {
                                    successBlock();
                                }
                            }];
}

#pragma mark - Tableview delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.resultsArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        ResultsTableViewCell *cell = (ResultsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ResultsTableViewCell" forIndexPath:indexPath];
        cell.result.text = @"Current Location";
        cell.icon.image = [UIImage imageNamed:@"gpsArrow"];
        [cell.editButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        return cell;
        
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont voicesFontWithSize:17];
        cell.textLabel.text = self.resultsArray[indexPath.row-1];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        [[LocationService sharedInstance]startUpdatingLocation];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else {
        self.searchBar.text = self.resultsArray[indexPath.row-1];
    }
}

@end
