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
#import "FBShimmeringView.h"
#import "FBShimmeringLayer.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *legislatureLevel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *legislatureLevelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *legislatureLevelLeadingConstraint;
@property (weak, nonatomic) NSLayoutConstraint *searchBarLeadingConstraint;
@property (weak, nonatomic) NSLayoutConstraint *searchBarTrailingConstraint;
@property (weak, nonatomic) NSLayoutConstraint *searchBarTopConstraint;
@property (weak, nonatomic) NSLayoutConstraint *searchBarBottomConstraint;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *voicesLabel;
@property (strong, nonatomic) FBShimmeringView *shimmeringView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search by address";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changePage:)
                                                 name:@"changePage"
                                               object:nil];
    [self prepareSearchBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // THIS NEEDS TO HAPPEN HERE BC CONSTRAINTS HAVE NOT APPEARED UNTIL HERE
    [self prepareVoicesLabel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Search Bar Delegate Methods

- (void)prepareSearchBar {
    self.searchBar.delegate = self;
        
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
    
    // HIDE THE SEARCH BAR FOR NOW
    self.searchBar.alpha = 0.0;
    self.searchButton.alpha = 1.0;
    self.legislatureLevel.alpha = 1.0;
    self.singleLineView.alpha = .5;
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


- (IBAction)openSearchBarButtonDidPress:(id)sender {
    [self showSearchBar];
}

- (void)showSearchBar {
    // REMOVE LABEL CONSTRAINTS
    [self.view removeConstraints:@[self.legislatureLevelLeadingConstraint, self.legislatureLevelTrailingConstraint]];
    
    // ADD SEARCH BAR CONSTRAINTS
    self.searchBarLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.searchView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    self.searchBarTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.searchView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    self.searchBarTopConstraint = [NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    self.searchBarBottomConstraint = [NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.searchView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.view addConstraints:@[self.searchBarLeadingConstraint, self.searchBarTrailingConstraint, self.searchBarTopConstraint, self.searchBarBottomConstraint]];

    self.searchBar.showsCancelButton = YES;
    self.isSearchBarOpen = YES;
    [self.searchBar becomeFirstResponder];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.searchBar.alpha = 1.0;
                         self.singleLineView.alpha = 0.0;
                         self.legislatureLevel.alpha = 0.0;
                         self.searchButton.alpha = 0.0;
                         [self.view layoutIfNeeded];
                         [self.view setNeedsUpdateConstraints];
                     }];
}

- (void)hideSearchBar {
    
    // REMOVE SEARCH BAR CONSTRAINTS
    if (self.searchBar.constraints.count) {
        [self.view removeConstraints:@[self.searchBarLeadingConstraint, self.searchBarTrailingConstraint, self.searchBarTopConstraint, self.searchBarBottomConstraint]];
    }
    
    // ADD LABEL CONSTRAINTS
    [self.view addConstraints:@[self.legislatureLevelLeadingConstraint, self.legislatureLevelTrailingConstraint]];

    self.isSearchBarOpen = NO;
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.searchBar.alpha = 0.0;
                         self.searchButton.alpha = 1.0;
                         self.legislatureLevel.alpha = 1.0;
                         self.singleLineView.alpha = .5;
                         [self.view layoutIfNeeded];
                         [self.view setNeedsUpdateConstraints];
                     }];
}

#pragma mark - Page Control and Shimmer

- (void)changePage:(NSNotification*)notification {
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
    
    if ([[userInfo valueForKey:@"currentPage"] isEqualToString:@"Congress"]) {
        self.pageControl.currentPage = 0;
    }
    else {
        self.pageControl.currentPage = 1;
    }
}


- (void)prepareVoicesLabel {
    self.shimmeringView = [[FBShimmeringView alloc]initWithFrame:self.voicesLabel.frame];
    [self.view addSubview:self.shimmeringView];
    self.voicesLabel.frame = self.shimmeringView.bounds;
    self.shimmeringView.contentView = self.voicesLabel;
    self.shimmeringView.shimmering = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setShimmer)
                                                 name:@"setShimmer"
                                               object:nil];
}

- (void)setShimmer {
    if (self.shimmeringView.shimmering) {
        self.shimmeringView.shimmering = NO;
    }
    else {
        self.shimmeringView.shimmering = YES;
    }
}
@end