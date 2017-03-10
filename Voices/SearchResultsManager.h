//
//  SearchResultsManager
//  Voices
//
//  Created by John Bogil on 2/16/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsManager : NSObject <UITableViewDelegate, UITableViewDataSource>

+ (SearchResultsManager *) sharedInstance;
@property (strong, nonatomic) NSArray *resultsArray;
@property (strong, nonatomic) NSString *homeAddress;
- (void)placeAutocomplete:(NSString *)searchText;

@end
