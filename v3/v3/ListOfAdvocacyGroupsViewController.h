//
//  ListOfAdvocacyGroupsViewController.h
//  Voices
//
//  Created by John Bogil on 4/20/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

// http://stackoverflow.com/questions/5210535/passing-data-between-view-controllers

#import <UIKit/UIKit.h>

@class ListOfAdvocacyGroupsViewController;

@protocol ViewControllerBDelegate <NSObject>
//- (void)addItemViewController:(ListOfAdvocacyGroupsViewController *)controller didFinishEnteringItem:(PFObject *)item;
@end

@interface ListOfAdvocacyGroupsViewController : UIViewController

@property (nonatomic, weak) id <ViewControllerBDelegate> delegate;


@end
