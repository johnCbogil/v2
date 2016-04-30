//
//  SearchResultsController.h
//  Voices
//
//  Created by Daniel Nomura on 4/29/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LocateOnTheMap <NSObject>

-(void) locateWithLongitude:(double) lon andLatitude:(double) late andTitle:(NSString*) string;

@end

@interface SearchResultsController : UITableViewController
@property (weak, nonatomic) id <LocateOnTheMap> delegate;
-(void)reloadDataWithArray:(NSMutableArray*) array;

@end

