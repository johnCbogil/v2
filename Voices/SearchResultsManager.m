//
//  SearchResultsManager
//  Voices
//
//  Created by John Bogil on 2/16/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "SearchResultsManager.h"
#import "LocationService.h"
#import "RepsManager.h"
#import "ResultsTableViewCell.h"

@import GooglePlaces;

@interface SearchResultsManager () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) GMSPlacesClient *placesClient;

@end

// TODO: CREATE SEARCHVC
// TODO: PUSH TO SEARCHVC
// TODO: HOME CELL SHOULD CHANGE TEXT WHEN THERE IS AN ADDRESS IN THE SAVED ADDRESS PROPERTY

@implementation SearchResultsManager

+ (SearchResultsManager *) sharedInstance {
    static SearchResultsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _placesClient = [[GMSPlacesClient alloc] init];
        self.resultsArray = @[];
        self.homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:@"homeAddress"];
        NSLog(@"HOME ADDRESS: %@", self.homeAddress);
    }
    return self;
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
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                    return;
                                }
                                NSMutableArray *tempArray = @[].mutableCopy;
                                for (GMSAutocompletePrediction* result in results) {
                                    NSLog(@"Result '%@'", result.attributedFullText.string);
                                    [tempArray addObject:result.attributedFullText.string];
                                }
                                self.resultsArray = tempArray;
                                if (successBlock) {
                                    successBlock();
                                }
                            }];
}

- (void)clearSearchResults {
    self.resultsArray = @[];
}

#pragma mark - Tableview delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.resultsArray.count) {
        return self.resultsArray.count + 2;
    }
    else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ResultsTableViewCell *cell = (ResultsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ResultsTableViewCell" forIndexPath:indexPath];
        cell.result.text = @"Current Location";
        cell.icon.image = [UIImage imageNamed:@"gpsArrow"];
        [cell.editButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        return cell;
        
    }
    else if (indexPath.row == 1) {
        ResultsTableViewCell *cell = (ResultsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ResultsTableViewCell" forIndexPath:indexPath];
        if (self.homeAddress.length) {
            cell.result.text = @"Home";
            cell.editButton.hidden = NO;
            
        }
        else {
            cell.result.text = @"Add Home Address";
            cell.editButton.hidden = YES;
        }
        
        cell.icon.image = [UIImage imageNamed:@"Home"];
        
        return cell;
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont voicesFontWithSize:17];
        cell.textLabel.text = self.resultsArray[indexPath.row - 2];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // TODO: SELECTED TEXT SHOULD APPEAR IN SEARCH BAR
    
    if (indexPath.row == 0) {
        [[LocationService sharedInstance]startUpdatingLocation];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hideSearchResultsTableView" object:nil];
        
    }
    else if (indexPath.row == 1) {
        if (self.homeAddress.length) {
            [self fetchRepsForAddress:self.homeAddress];
        }
        else {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"presentSearchViewController" object:nil];
        }
    }
    else {
        
        [self fetchRepsForAddress:self.resultsArray[indexPath.row - 2]];
    }
}

- (void)fetchRepsForAddress:(NSString *)address {
    
    [[LocationService sharedInstance]getCoordinatesFromSearchText:address withCompletion:^(CLLocation *locationResults) {
        NSLog(@"%@", locationResults);
        [[RepsManager sharedInstance]createFederalRepresentativesFromLocation:locationResults WithCompletion:^{
            NSLog(@"%@", locationResults);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
        
        [[RepsManager sharedInstance]createStateRepresentativesFromLocation:locationResults WithCompletion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
        
        [[RepsManager sharedInstance]createNYCRepsFromLocation:locationResults];
        
    } onError:^(NSError *googleMapsError) {
        NSLog(@"%@", [googleMapsError localizedDescription]);
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"hideSearchResultsTableView" object:nil];
}

@end
