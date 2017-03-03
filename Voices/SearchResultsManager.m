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
@property (strong, nonatomic) NSString *homeAddress;

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

- (id)init {
    self = [super init];
    if(self != nil) {
        
        _placesClient = [[GMSPlacesClient alloc] init];
        self.resultsArray = @[];
        
    }
    return self;
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
    if (self.resultsArray.count) {
        return self.resultsArray.count;
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
        }
        else {
            cell.result.text = @"Add Home Address";
        }
        
        cell.icon.image = [UIImage imageNamed:@"Home"];
        
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
    
    // TODO: SELECTED TEXT SHOULD APPEAR IN SEARCH BAR
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"dismissKeyboard" object:nil];
    
    if (indexPath.row == 0) {
        [[LocationService sharedInstance]startUpdatingLocation];
    }
    else if (indexPath.row == 1) {
        // TODO: PUSH TO SEARCHVC
    }
    else {
        [[LocationService sharedInstance]getCoordinatesFromSearchText:self.resultsArray[indexPath.row-2] withCompletion:^(CLLocation *locationResults) {
            
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
    }
}

@end
