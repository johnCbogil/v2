//
//  HomeViewController.h
//  v2
//
//  Created by John Bogil on 8/7/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface HomeViewController : UIViewController <UISearchBarDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) PageViewController *pageVC;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIView *singleLineView;
@property (nonatomic) BOOL isSearchBarOpen;
@end