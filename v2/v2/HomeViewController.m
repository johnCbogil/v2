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
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *shimmer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voicesLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voicesLabelCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voicesLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voicesLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voicesLabelBottomConstraint;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentEmailViewController)
                                                 name:@"presentEmailVC"
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
    self.shimmeringView = [[FBShimmeringView alloc]initWithFrame:self.shimmer.frame];
    [self.view addSubview:self.shimmeringView];
    self.voicesLabel.frame = self.shimmeringView.frame;
    self.shimmeringView.contentView = self.voicesLabel;
    self.shimmeringView.shimmering = NO;

//    FBShimmeringLayer *shimmeringLayer = [[FBShimmeringLayer alloc]initWithLayer:self.voicesLabel.layer];
//    [self.view.layer addSublayer:shimmeringLayer];
//    self.voicesLabel.layer.frame = shimmeringLayer.bounds;
//    shimmeringLayer.contentLayer = self.voicesLabel.layer;
//    shimmeringLayer.shimmering = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setShimmer)
                                                 name:@"setShimmer"
                                               object:nil];
    
//    [self.view addConstraints:@[self.voicesLabelBottomConstraint, self.voicesLabelCenterXConstraint, self.voicesLabelLeadingConstraint, self.voicesLabelTopConstraint, self.voicesLabelTrailingConstraint ]];
    
//    NSLayoutConstraint *shimmeringViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.shimmeringView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
//    NSLayoutConstraint *shimmeringViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.shimmeringView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
//    NSLayoutConstraint *shimmeringViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.shimmeringView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
//    NSLayoutConstraint *shimmeringViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.shimmeringView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
//    
//    [self.view addConstraints:@[shimmeringViewBottomConstraint, shimmeringViewLeadingConstraint, shimmeringViewTrailingConstraint]];


}

- (void)viewDidLayoutSubviews {
    NSLog(@"My view's frame is: %@", NSStringFromCGRect(self.voicesLabel.frame));

}

- (void)setShimmer {
    if (self.shimmeringView.shimmering) {
        self.shimmeringView.shimmering = NO;
    }
    else {
        self.shimmeringView.shimmering = YES;
    }
}

- (void)presentEmailViewController {

    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
//    if (mailViewController.canSendMail == YES) {
//
//    }
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:@";Subject Goes Here."];
    [mailViewController setMessageBody:@";Your message goes here." isHTML:NO];
    [self presentViewController:mailViewController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error

{
    UIAlertView *alert;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            alert = [[UIAlertView alloc] initWithTitle:@"Draft Saved" message:@"Composed Mail is saved in draft." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        case MFMailComposeResultSent:
            alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully referred your friends." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        case MFMailComposeResultFailed:
            alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Sorry! Failed to send." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end