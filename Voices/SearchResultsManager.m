//
//  SearchResultsManager
//  Voices
//
//  Created by John Bogil on 2/16/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "SearchResultsManager.h"
#import "LocationService.h"

@import GooglePlaces;

@interface SearchResultsManager () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) GMSPlacesClient *placesClient;

@end

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
                                    [tempArray addObject:result.attributedFullText];
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
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Current Location";
    }
    else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.attributedText = self.resultsArray[indexPath.row];
        return cell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {

        [[LocationService sharedInstance]startUpdatingLocation];
        // TODO: HIDE KEYBOARD

    }
    
}

@end
