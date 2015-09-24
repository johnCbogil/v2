//
//  HomeViewController.m
//  v2
//
//  Created by John Bogil on 8/7/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "HomeViewController.h"
#import "NetworkManager.h"
#import "LocationService.h"
#import "RepManager.h"
#import "CustomSearchBar.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *legislatureLevel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *legislatureLevelTrailingConstraint;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search by address";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLabel:)
                                                 name:@"changeLabel"
                                               object:nil];
    [self prepareSearchBar];

}

- (void)changeLabel:(NSNotification*)notification {
    NSDictionary* userInfo = notification.object;
    if ([userInfo objectForKey:@"currentPage"]) {
            self.legislatureLevel.text = [userInfo valueForKey:@"currentPage"];
    }

    CGSize maximumLabelSize = CGSizeMake(225,CGFLOAT_MAX);
    CGSize requiredSize = [self.legislatureLevel sizeThatFits:maximumLabelSize];
    CGRect labelFrame = self.legislatureLevel.frame;
    labelFrame.size.width = requiredSize.width;

    
    self.legislatureLevel.frame = labelFrame;
    [UIView animateWithDuration:.15
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    for (id vc in self.childViewControllers) {
        if ([vc isKindOfClass:[UIPageViewController class]]) {
            self.pageVC = vc;
        }
    }
    [[LocationService sharedInstance]getCoordinatesFromSearchText:searchBar.text withCompletion:^(CLLocation *results) {
        if ([[self.pageVC.viewControllers[0]title] isEqualToString: @"Congress"]) {
            [[RepManager sharedInstance]createCongressmenFromLocation:results WithCompletion:^{
                NSLog(@"%@", results);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCongressTableView" object:nil];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
        else {
            [[LocationService sharedInstance]getCoordinatesFromSearchText:searchBar.text withCompletion:^(CLLocation *results) {
                [[RepManager sharedInstance]createStateLegislatorsFromLocation:results WithCompletion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadStateLegislatorTableView" object:nil];

                } onError:^(NSError *error) {
                    [error localizedDescription];
                }];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
    } onError:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self hideSearchBar];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)prepareSearchBar {
    self.searchBar.delegate = self;
    
    [self hideSearchBar];
    
    // ROUND THE BOX
    self.searchView.layer.cornerRadius = 5;
    self.searchView.clipsToBounds = YES;
    
    // Set cancel button to white color
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]forState:UIControlStateNormal];
    
    // Set placeholder text to white
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil]setTextColor:[UIColor whiteColor]];
    
    // Set the input text font
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setDefaultTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Avenir" size:15],NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // HIDE THE MAGNYIFYING GLASS
    [self.searchBar setImage:[UIImage new]
            forSearchBarIcon:UISearchBarIconSearch
                       state:UIControlStateNormal];
    
    // SET THE CURSOR POSITION
    [[UISearchBar appearance] setPositionAdjustment:UIOffsetMake(-20, 0)
                                   forSearchBarIcon:UISearchBarIconSearch];
    
    [self.searchBar setTintColor:[UIColor whiteColor]];
    
    // SET THE CURSOR COLOR
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setTintColor:[UIColor colorWithRed:255.0 / 255.0
                                  green:160.0 / 255.0
                                   blue:5.0 / 255.0
                                  alpha:1.0]];
    
    // SET THE CLEAR BUTTON FOR BOTH STATES
    [self.searchBar setImage:[UIImage imageNamed:@"ClearButton"]
            forSearchBarIcon:UISearchBarIconClear
                       state:UIControlStateHighlighted];
    [self.searchBar setImage:[UIImage imageNamed:@"ClearButton"]
            forSearchBarIcon:UISearchBarIconClear
                       state:UIControlStateNormal];
    
    // ROUND THE SEARCH BAR
    UITextField *txfSearchField = [self.searchBar valueForKey:@"_searchField"];
    txfSearchField.layer.cornerRadius = 13;
}

- (IBAction)openSearchBarButtonDidPress:(id)sender {
    [self showSearchBar];
}

- (void)showSearchBar {
    
    
    // GET THE SIZE OF THE LABEL
    
    // GET THE SIZE OF THE SEARCHBAR
    
    // SUBTRACT THE DIFFERENCE
    
    // ADD THIS DIFFERENCE TO THE LEGLEVEL CONSTRAINT
    
    
    
    self.searchBar.showsCancelButton = YES;
    self.isSearchBarOpen = YES;
    [self.searchBar becomeFirstResponder];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.legislatureLevelTrailingConstraint.constant = (self.searchBar.frame.size.width - self.legislatureLevel.frame.size.width);
                         self.searchBar.alpha = 1.0;
                         self.singleLineView.alpha = 0.0;
                         self.legislatureLevel.alpha = 0.0;
                         self.searchButton.alpha = 0.0;
                         [self.view setNeedsDisplay];
                     }];
}

- (void)hideSearchBar {
    self.isSearchBarOpen = NO;
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.legislatureLevelTrailingConstraint.constant = 54;
                         self.searchBar.alpha = 0.0;
                         self.searchButton.alpha = 1.0;
                         self.legislatureLevel.alpha = 1.0;
                         self.singleLineView.alpha = .5;
                         [self.view setNeedsDisplay];
                     }];
}
@end