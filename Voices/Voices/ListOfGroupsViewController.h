//
//  ListOfGroupsViewController.h
//  Voices
//
//  Created by John Bogil on 4/20/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

// http://stackoverflow.com/questions/5210535/passing-data-between-view-controllers

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class ListOfGroupsViewController;

@protocol ViewControllerBDelegate <NSObject>
- (void)addItemViewController:(ListOfGroupsViewController *)controller didFinishEnteringItem:(PFObject *)item;
@end

@interface ListOfGroupsViewController : UIViewController

@property (nonatomic, weak) id <ViewControllerBDelegate> delegate;


@end
