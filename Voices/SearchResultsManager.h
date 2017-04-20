//
//  SearchResultsManager
//  Voices
//
//  Created by John Bogil on 2/16/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchResultsManager : NSObject <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic) NSString *searchMethod;
@property (strong, nonatomic) NSArray *resultsArray;
@property (strong, nonatomic) NSString *addressSearched;

- (void)placeAutocomplete:(NSString *)searchText onSuccess:(void(^)(void))successBlock;
- (void)clearSearchResults;
+ (SearchResultsManager *) sharedInstance;


@end
