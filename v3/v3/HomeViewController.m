//
//  HomeViewController.m
//  Voices
//
//  Created by John Bogil on 8/7/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "HomeViewController.h"
#import "NetworkManager.h"
#import "RepManager.h"
#import "UIFont+voicesFont.h"
#import "StateRepresentative.h"
#import "CacheManager.h"
#import "UIColor+voicesOrange.h"
#import "PageViewController.h"
#import "LocationService.h"
#import "VoicesConstants.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>
#import <STPopup/STPopup.h>
#import <Google/Analytics.h>
#import "FBShimmeringView.h"
#import "FBShimmeringLayer.h"
#import "SearchResultsController.h"

static NSString *const cellIdentifier = @"cellIdentifier";
static NSString *const segueIdentifier = @"embedPageVC";
static BOOL didTryToShowSearchTableViewAgain = NO;
static BOOL didSearchButNoResults = NO;


@interface HomeViewController () <MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *legislatureLevel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIImageView *magnifyingGlass;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shimmerViewWidthConstraint;
@property (assign, nonatomic) CGFloat searchViewDefaultWidth;
@property (assign, nonatomic) CGFloat shimmerViewDefaultWidth;
@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (strong, nonatomic) NSString *representativeEmail;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;
@property (strong, nonatomic) UIVisualEffectView *blurView;
@property (nonatomic) BOOL isBlurViewPresent;

//PageViewController Properties
@property (weak, nonatomic) PageViewController *pageViewController;
@property (weak, nonatomic) UIScrollView *pageVCScrollView;
@property (strong, nonatomic) UIPanGestureRecognizer *turnPageRecognizer;

//Search autocomplete properties
@property (strong, nonatomic) NSArray *searchResultsArray;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (nonatomic) BOOL isSearchTableViewPresent;
@property (nonatomic) BOOL didNumberOfSearchResultsChange;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObservers];
    [self setFont];
    [self setColors];
    [self setSearchBar];
    [self setShimmer];
    [self setupSearchTableView];
    [self setBlurView];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // To get the turnPage gesture recognizer in the PageViewController's scrollView
    if ([segue.identifier isEqualToString:segueIdentifier]) {
        self.pageViewController = [segue destinationViewController];
        for (UIView *view in self.pageViewController.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                self.pageVCScrollView = (UIScrollView*) view;
                self.turnPageRecognizer = self.pageVCScrollView.panGestureRecognizer;
            }
        }
    }
}

#pragma mark - Setup Methods


- (void)setColors {
    self.searchView.backgroundColor = [UIColor voicesOrange];
    self.infoButton.tintColor = [[UIColor blackColor]colorWithAlphaComponent:.5];
    self.pageControl.pageIndicatorTintColor = [[UIColor blackColor]colorWithAlphaComponent:.2];
}

- (void)setBlurView {
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    [self.blurView setFrame:self.pageVCScrollView.frame];
    UIColor *backgroundColor = [[UIColor voicesOrange] colorWithAlphaComponent:.3];
    self.blurView.backgroundColor = backgroundColor;
    self.blurView.opaque = NO;
    self.blurView.hidden = YES;
    self.isBlurViewPresent = NO;
    [self.containerView addSubview:self.blurView];
}


- (void)setFont {
    self.legislatureLevel.font = [UIFont voicesFontWithSize:27];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePageFinished:) name:kNotifyFinishPageChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startChangePage) name:kNotifyStartPageChange object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard) name:kNotifyTableCellButtonPressed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEmailViewController:) name:@"presentEmailVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTweetComposer:)name:@"presentTweetComposer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentInfoViewController)name:@"presentInfoViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingOperationDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidSuspendNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidCompleteNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)note {
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.containerView addGestureRecognizer:self.tap];
    self.tap.delegate = self;
}



- (void)setupSearchTableView {
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    
    [self.searchTableView registerClass:[UITableViewCell class] forCellReuseIdentifier: cellIdentifier];
    self.isSearchTableViewPresent = NO;
    self.didNumberOfSearchResultsChange = NO;
}

- (void)setSearchBar {
    
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search by location";
    
    self.searchViewDefaultWidth = self.searchViewWidthConstraint.constant;
    self.shimmerViewDefaultWidth = self.shimmerViewWidthConstraint.constant;
    
    // Round the box
    self.searchView.layer.cornerRadius = 5;
    self.searchView.clipsToBounds = YES;
    
    // Set cancel button to white color
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]forState:UIControlStateNormal];
    
    // Set placeholder text to white
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil]setTextColor:[UIColor whiteColor]];
    
    // Set the input text font
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setDefaultTextAttributes:@{NSFontAttributeName : [UIFont voicesFontWithSize:15],NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // Hide the magnifying glass
    [self.searchBar setImage:[UIImage new]
            forSearchBarIcon:UISearchBarIconSearch
                       state:UIControlStateNormal];
    
    // Set the cursor position
    [[UISearchBar appearance] setPositionAdjustment:UIOffsetMake(-20, 0)
                                   forSearchBarIcon:UISearchBarIconSearch];
    
    [self.searchBar setTintColor:[UIColor whiteColor]];
    
    // Set the cursor color
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setTintColor:[UIColor colorWithRed:255.0 / 255.0
                                  green:160.0 / 255.0
                                   blue:5.0 / 255.0
                                  alpha:1.0]];
    
    // Set the clear button for both states
    [self.searchBar setImage:[UIImage imageNamed:@"ClearButton"]
            forSearchBarIcon:UISearchBarIconClear
                       state:UIControlStateHighlighted];
    [self.searchBar setImage:[UIImage imageNamed:@"ClearButton"]
            forSearchBarIcon:UISearchBarIconClear
                       state:UIControlStateNormal];
    
    // Round the search bar
    UITextField *textSearchField = [self.searchBar valueForKey:@"_searchField"];
    textSearchField.layer.cornerRadius = 13;
    
    // Hide the search bar
    self.searchBar.alpha = 0.0;
    self.searchButton.alpha = 1.0;
    self.magnifyingGlass.alpha = 1.0;
    self.legislatureLevel.alpha = 1.0;
    self.singleLineView.alpha = .5;
}

- (void)dismissKeyboard {
    [self.searchBar resignFirstResponder];
    [self hideSearchBar];
    [self.containerView removeGestureRecognizer:self.tap];
    [self hideSearchTableView];
}

- (void)dismissKeyboardButKeepSearchBarOpen {
    [self.searchBar resignFirstResponder];
    [self.containerView removeGestureRecognizer:self.tap];
    [self hideSearchTableView];
}



//#pragma mark - Gesture recognizer delegate implementation
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    
//    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
//        return YES;
//        //        if ([touch.view isEqual:self.blurView])  {
//        //            return YES;
//        //        }
//    }
//    return YES;
//}

#pragma mark - GeoLocation Methods

- (void)findRepsFromLocationWithSearchResult:(NSString*) result{
    [[LocationService sharedInstance]getCoordinatesFromSearchText:result withCompletion:^(CLLocation *locationResults) {
        
        [[RepManager sharedInstance]createFederalRepresentativesFromLocation:locationResults WithCompletion:^{
            NSLog(@"%@", locationResults);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
        
        [[RepManager sharedInstance]createStateRepresentativesFromLocation:locationResults WithCompletion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
        
        [[RepManager sharedInstance]createNYCRepsFromLocation:locationResults];
        
    } onError:^(NSError *googleMapsError) {
        NSLog(@"%@", [googleMapsError localizedDescription]);
    }];
}

- (void)handleAddressesFromSearchText:(NSString*)searchText {
    [[NetworkManager sharedInstance] getAddressesFromSearchText:searchText withCompletion:^(NSDictionary *results) {
        NSMutableArray *resultsArray = [NSMutableArray new];
        
        for (NSDictionary *dictionary in [results objectForKey:@"predictions"]) {
            NSString *address = [dictionary objectForKey:@"description"];
            
            //Uncomment to remove ", United States" from the search results
//            NSString *omitString = @", United States";
//            NSRange possibleOmitRange = NSMakeRange(address.length - omitString.length, omitString.length);
//            NSString *testString = [address substringWithRange:possibleOmitRange];
//            if ([testString isEqualToString: omitString]) {
//                address = [address substringToIndex:(address.length - omitString.length)];
//            }
            [resultsArray addObject:address];
        }
        
        NSInteger previousNumberOfSearchResults = self.searchResultsArray.count;
        NSInteger currentNumberOfSearchResults = resultsArray.count;
        self.searchResultsArray = [NSArray arrayWithArray:resultsArray];
        
        self.didNumberOfSearchResultsChange = previousNumberOfSearchResults == currentNumberOfSearchResults ? NO : YES;
        
        didSearchButNoResults = self.searchResultsArray.count == 0 ? YES : NO;
        
        [self.searchTableView reloadData];
        
        [self showSearchTableView];

    } onError:^(NSError *error) {
        NSLog(@"Error getting autocomplete results from Google Places API: \n%@\n%@", error.localizedDescription, error.userInfo);
    }];
}



#pragma mark - FB Shimmer methods

- (void)setShimmer {
    self.searchView.frame = self.shimmeringView.bounds;
    self.shimmeringView.contentView = self.searchView;
}

- (void)toggleShimmerOn {
    self.shimmeringView.shimmering = YES;
}

- (void)toggleShimmerOff {
    [self.shimmeringView performSelector:@selector(setShimmering:)];
    self.shimmeringView.shimmering = NO;
}


#pragma mark - Animation Methods
- (void)blurContainerView {
    if (!self.isBlurViewPresent) {
        [UIView animateWithDuration:0.3 animations:^{
            self.blurView.hidden = NO;
        } completion:^(BOOL finished) {
            if (finished) {
                self.isBlurViewPresent = YES;
                [self.blurView addGestureRecognizer:self.turnPageRecognizer];
            } else {
                NSLog(@"Container view did not blur");
            }
        }];
    }
}

- (void)unblurContainerView {
    if (self.isBlurViewPresent) {
        [UIView animateWithDuration:0.1 animations:^{
            self.blurView.hidden = YES;
        } completion:^(BOOL finished) {
            if (finished) {
                self.isBlurViewPresent = NO;
                [self.pageVCScrollView addGestureRecognizer:self.turnPageRecognizer];
            } else {
                NSLog(@"Container view did not unblur");
            }
        }];
    }
}
- (void)showSearchBar {
    self.searchViewWidthConstraint.constant = self.view.frame.size.width / 1.25;
    self.shimmerViewWidthConstraint.constant = self.view.frame.size.width / 1.25;
    
    self.searchBar.showsCancelButton = YES;
    [self.searchBar becomeFirstResponder];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.searchBar.alpha = 1.0;
                         self.singleLineView.alpha = 0.0;
                         self.legislatureLevel.alpha = 0.0;
                         self.searchButton.alpha = 0.0;
                         self.magnifyingGlass.alpha = 0.0;
                         [self.view layoutIfNeeded];
                         [self.view setNeedsUpdateConstraints];
                     } completion:^(BOOL finished) {
                         if (finished) {
                             self.isSearchBarOpen = YES;
                         } else {
                             NSLog(@"Search bar did not show");
                         }
                     }];
}

- (void)hideSearchBar {
    self.searchViewWidthConstraint.constant = [self searchViewWidth];
    self.shimmerViewWidthConstraint.constant = [self shimmerViewWidth];
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.searchBar.alpha = 0.0;
                         self.searchButton.alpha = 1.0;
                         self.magnifyingGlass.alpha = 1.0;
                         self.legislatureLevel.alpha = 1.0;
                         self.singleLineView.alpha = .5;
                         [self.view layoutIfNeeded];
                         [self.view setNeedsUpdateConstraints];
                     } completion:^(BOOL finished) {
                         if (finished) {
                             self.isSearchBarOpen = NO;
                         } else {
                             NSLog(@"Search bar did not hide");
                         }
                     }];
}

- (void)showSearchTableView {
    self.isSearchTableViewPresent = self.searchTableView.frame.size.height == 0 ? NO : YES;
    
    if (!self.isSearchTableViewPresent || self.didNumberOfSearchResultsChange) {
        [UIView animateWithDuration:0.25 animations:^{
            float tableViewCellMultiplier = self.searchResultsArray.count < 5 ? self.searchResultsArray.count : 4.15;
            
            CGFloat height = tableViewCellMultiplier * 44;
            [self.searchTableView setFrame: CGRectMake(self.searchTableView.frame.origin.x,
                                                       self.searchTableView.frame.origin.y,
                                                       self.searchTableView.frame.size.width,
                                                       height)];
        } completion:^(BOOL finished) {
            if (finished) {
                if (self.searchTableView.frame.size.height == 0 && self.searchResultsArray.count != 0) {
                    

                    if (didTryToShowSearchTableViewAgain) {
                        didTryToShowSearchTableViewAgain = NO;
                        return;
                    }
                    didTryToShowSearchTableViewAgain = YES;
                    [self showSearchTableView];
                    
                    // Without this ^^ recursion, sometimes TableView does not show after animation, so user has to type in another character to get the search results to show. Will retry the animation only once
                    
                } else {
                    self.isSearchTableViewPresent = YES;
                    self.didNumberOfSearchResultsChange = NO;
                    didTryToShowSearchTableViewAgain = NO;
                    [self blurContainerView];
                }
            } else {
                NSLog(@"Search TableView did not show");
            }
        }];
    }
}

- (void)hideSearchTableView {
    if (self.isSearchTableViewPresent || didSearchButNoResults) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.searchTableView setFrame: CGRectMake(self.searchTableView.frame.origin.x,
                                                       self.searchTableView.frame.origin.y,
                                                       self.searchTableView.frame.size.width,
                                                       0)];
        } completion:^(BOOL finished) {
            if (finished) {
                self.isSearchTableViewPresent = NO;
                [self unblurContainerView];
                didSearchButNoResults = NO;
            } else {
                NSLog(@"Search TableView did not hide");
            }
        }];
    }
}


#pragma mark - Search Bar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    for (id vc in self.childViewControllers) {
        if ([vc isKindOfClass:[UIPageViewController class]]) {
            self.pageViewController = vc;
        }
    }
    [self findRepsFromLocationWithSearchResult:searchBar.text];
    [self dismissKeyboard];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissKeyboard];
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
}


- (IBAction)openSearchBarButtonDidPress:(id)sender {
    [self showSearchBar];
}



- (CGFloat)searchViewWidth {
    return self.legislatureLevel.intrinsicContentSize.width + 60;
}

- (CGFloat)shimmerViewWidth {
    return self.legislatureLevel.intrinsicContentSize.width + 60;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (self.searchBar.text.length > 0) {
        [self handleAddressesFromSearchText:searchBar.text];
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        [self handleAddressesFromSearchText:searchText];
    }
    if (searchText.length == 0) {
        [self hideSearchTableView];
//        [self.pageVCScrollView addGestureRecognizer:self.turnPageRecognizer];
    }
}



#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResultsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.searchResultsArray[indexPath.row];
    
    // Configure the cell...
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *address = [self.searchResultsArray objectAtIndex:indexPath.row];
    self.searchBar.text = address;
    [self findRepsFromLocationWithSearchResult:address];
    [self dismissKeyboardButKeepSearchBarOpen];
}



#pragma mark - Presentation Controllers

- (void)presentEmailViewController:(NSNotification*)notification {
    self.representativeEmail = [notification object];
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {
        mailViewController.mailComposeDelegate = self;
        //        [mailViewController setSubject:@"Subject Goes Here."];
        //        [mailViewController setMessageBody:@"Your message goes here." isHTML:NO];
        [mailViewController setToRecipients:@[self.representativeEmail]];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    UIAlertView *alert;
    switch (result) {
        case MFMailComposeResultCancelled:
        {
            break;
        }
        case MFMailComposeResultSaved:
            alert = [[UIAlertView alloc] initWithTitle:@"Draft Saved" message:@"Composed Mail is saved in draft." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        case MFMailComposeResultSent:
        {
            alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"direct_action"
                                                                  action:@"email_sent"
                                                                   label:self.representativeEmail
                                                                   value:@1] build]];
            break;
        }
        case MFMailComposeResultFailed:
            alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Sorry! Failed to send." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentTweetComposer:(NSNotification*)notification {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *initialText = [NSString stringWithFormat:@".@%@", [notification.userInfo objectForKey:@"accountName"]];
        [tweetSheetOBJ setInitialText:initialText];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tweetSheetOBJ setCompletionHandler:^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Twitter Post Canceled");

                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Twitter Post Sucessful");
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"direct_action"
                                                                          action:@"tweet_sent"
                                                                           label:[notification.userInfo objectForKey:@"accountName"]
                                                                           value:@1] build]];
                    break;
                default:
                    break;
            }
        }];
        [self presentViewController:tweetSheetOBJ animated:YES completion:nil];
    }
}

- (IBAction)infoButtonDidPress:(id)sender {
    [self presentInfoViewController];
}

- (void)presentInfoViewController {
    UIViewController *infoViewController = [[UIStoryboard storyboardWithName:@"Info" bundle:nil] instantiateViewControllerWithIdentifier:@"InfoViewController"];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:infoViewController];
    popupController.cornerRadius = 10;
    if (NSClassFromString(@"UIBlurEffect")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor]; // This is the only OK "orangeColor", for now
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:23], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:19] } forState:UIControlStateNormal]; 
    [popupController presentInViewController:self];
}

- (void)startChangePage {
    [self dismissKeyboardButKeepSearchBarOpen];
}


- (void)changePageFinished:(NSNotification *)notification {
    NSDictionary* userInfo = notification.object;
    if ([userInfo objectForKey:@"currentPage"]) {
        self.legislatureLevel.text = [userInfo valueForKey:@"currentPage"];
    }
    
    
    if (!self.isSearchBarOpen) {
        self.searchViewWidthConstraint.constant = [self searchViewWidth];
        self.shimmerViewWidthConstraint.constant = [self shimmerViewWidth];
        
        [UIView animateWithDuration:.15
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }

    if ([[userInfo valueForKey:@"currentPage"] isEqualToString:@"Congress"]) {
        self.pageControl.currentPage = 0;
    }
    else if ([[userInfo valueForKey:@"currentPage"] isEqualToString:@"State Legislators"]) {
        self.pageControl.currentPage = 1;
    }
    else {
        self.pageControl.currentPage = 2;
    }
}



@end