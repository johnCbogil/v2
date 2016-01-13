//
//  HomeViewController.m
//  v2
//
//  Created by John Bogil on 8/7/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "HomeViewController.h"
#import "NetworkManager.h"
#import "RepManager.h"
#import "StateLegislator.h"
//#import "FBShimmeringView.h"
//#import "FBShimmeringLayer.h"
#import "InfoPageViewController.h"
#import <Social/Social.h>
#import <STPopup/STPopup.h>
#import "UIFont+voicesFont.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *legislatureLevel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
//@property (weak, nonatomic) IBOutlet UILabel *voicesLabel;
//@property (strong, nonatomic) FBShimmeringView *shimmeringView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
//@property (weak, nonatomic) IBOutlet UIView *shimmer;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *zeroStateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *magnifyingGlass;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewWidthConstraint;
@property (assign, nonatomic) CGFloat searchViewDefaultWidth;
@property (strong, nonatomic) NSString *stateLowerDistrictNumber;
@property (strong, nonatomic) NSString *stateUpperDistrictNumber;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UILabel *callToActionLabel;
@property (weak, nonatomic) IBOutlet UIView *zeroStateContainer;
@property (weak, nonatomic) IBOutlet UIImageView *zeroStateImageView;

@end

@implementation HomeViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([CLLocationManager authorizationStatus] < 2) {
        self.zeroStateContainer.alpha = 1;
    }
    else {
        self.zeroStateContainer.alpha = 0;
        
        // TODO: THIS CODE IS NOT DRY
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSData *dataRepresentingCachedCongresspersons = [currentDefaults objectForKey:@"cachedCongresspersons"];
        if (dataRepresentingCachedCongresspersons != nil) {
            NSArray *oldCachedCongresspersons = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingCachedCongresspersons];
            if (oldCachedCongresspersons != nil)
                [RepManager sharedInstance].listOfCongressmen = [[NSMutableArray alloc] initWithArray:oldCachedCongresspersons];
        }
        else {
            [RepManager sharedInstance].listOfCongressmen = [[NSMutableArray alloc] init];
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
                [[LocationService sharedInstance]startUpdatingLocation];
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchViewDefaultWidth = self.searchViewWidthConstraint.constant;
    
    [self addObservers];
    [self setFont];
    [self prepareSearchBar];
    
    // IF LOCATION SERVICE DENIED, DISPLAY ZEROSTATE
    if ([CLLocationManager authorizationStatus] < 2) {
        self.zeroStateContainer.alpha = 1;
        self.zeroStateLabel.text = @"Turn on location services, or try searching by location above.";
    }
    else {
        self.zeroStateContainer.alpha = 0;
    }
}

- (void)setFont {
    self.callToActionLabel.font = [UIFont voicesFontWithSize:24];
    self.legislatureLevel.font = [UIFont voicesFontWithSize:27];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // THIS NEEDS TO HAPPEN HERE BC CONSTRAINTS HAVE NOT APPEARED UNTIL VDA
    //   [self prepareShimmer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changePage:)
                                                 name:@"changePage"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentEmailViewController:)
                                                 name:@"presentEmailVC"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentTweetComposer:)
                                                 name:@"presentTweetComposer"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentInfoViewController)
                                                 name:@"presentInfoViewController"
                                               object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(toggleZeroStateLabel)
    //                                                 name:AFNetworkingReachabilityDidChangeNotification
    //                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toggleZeroStateLabel)
                                                 name:@"toggleZeroStateLabel"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInformationLabel:)
                                                 name:@"updateInformationLabel"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInformationLabel:) name:AFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInformationLabel:) name:AFNetworkingOperationDidFinishNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInformationLabel:) name:AFNetworkingTaskDidSuspendNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidCompleteNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)note
{
    self.tap = [[UITapGestureRecognizer alloc]
                initWithTarget:self
                action:@selector(dismissKeyboard)];
    [self.containerView addGestureRecognizer:self.tap];
}

- (void)dismissKeyboard {
    [self hideSearchBar];
    [self.searchBar resignFirstResponder];
    [self.containerView removeGestureRecognizer:self.tap];
}

#pragma mark - Search Bar Delegate Methods

- (void)prepareSearchBar {
    
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search by location";
    
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
     setDefaultTextAttributes:@{NSFontAttributeName : [UIFont voicesFontWithSize:15],NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
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
    UITextField *textSearchField = [self.searchBar valueForKey:@"_searchField"];
    textSearchField.layer.cornerRadius = 13;
    
    // HIDE THE SEARCH BAR FOR NOW
    self.searchBar.alpha = 0.0;
    self.searchButton.alpha = 1.0;
    self.magnifyingGlass.alpha = 1.0;
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
                //NSLog(@"%@", results);
                self.zeroStateContainer.alpha = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCongressTableView" object:nil];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
        else {
            [[LocationService sharedInstance]getCoordinatesFromSearchText:searchBar.text withCompletion:^(CLLocation *results) {
                [[RepManager sharedInstance]createStateLegislatorsFromLocation:results WithCompletion:^{
                    self.zeroStateContainer.alpha = 0;
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
    [self hideSearchBar];
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
    self.searchViewWidthConstraint.constant = self.view.frame.size.width / 1.25;
    self.searchBar.showsCancelButton = YES;
    self.isSearchBarOpen = YES;
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
                     }];
}

- (void)hideSearchBar {
    
    self.searchViewWidthConstraint.constant = [self searchViewWidth];
    
    self.isSearchBarOpen = NO;
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
                     }];
}

- (CGFloat)searchViewWidth {
    return self.legislatureLevel.intrinsicContentSize.width + 60;
}

- (void)changePage:(NSNotification*)notification {
    NSDictionary* userInfo = notification.object;
    if ([userInfo objectForKey:@"currentPage"]) {
        self.legislatureLevel.text = [userInfo valueForKey:@"currentPage"];
    }
    
    self.searchViewWidthConstraint.constant = [self searchViewWidth];
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
    [self updateInformationLabel:nil];
}

//#pragma mark - Shimmer
//
//- (void)prepareShimmer {
//    self.shimmeringView = [[FBShimmeringView alloc]initWithFrame:self.shimmer.frame];
//    [self.view addSubview:self.shimmeringView];
//    self.voicesLabel.frame = self.shimmeringView.frame;
//    //self.shimmeringView.contentView = self.voicesLabel;
//    self.shimmeringView.shimmering = NO;
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingOperationDidStartNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingOperationDidFinishNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingTaskDidResumeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidSuspendNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidCompleteNotification object:nil];
//}

- (void)viewDidLayoutSubviews {
    //NSLog(@"My view's frame is: %@", NSStringFromCGRect(self.voicesLabel.frame));
}

////- (void)toggleShimmerOn {
////    [NSObject cancelPreviousPerformRequestsWithTarget:self.shimmeringView selector:@selector(setShimmering:) object:@NO];
////    self.shimmeringView.shimmering = YES;
////}
//
//- (void)toggleShimmerOff {
//    [self.shimmeringView performSelector:@selector(setShimmering:) withObject:@NO afterDelay:0.5];
//}

#pragma mark - Presentation Controllers

- (void)presentEmailViewController:(NSNotification*)notification {
    NSString *repEmail = [notification object];
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {
        mailViewController.mailComposeDelegate = self;
        //        [mailViewController setSubject:@"Subject Goes Here."];
        //        [mailViewController setMessageBody:@"Your message goes here." isHTML:NO];
        [mailViewController setToRecipients:@[repEmail]];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
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
            alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
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

- (void)presentTweetComposer:(NSNotification*)notification {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheetOBJ = [SLComposeViewController
                                                  composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *initialText = [NSString stringWithFormat:@"@%@", [notification.userInfo objectForKey:@"accountName"]];
        [tweetSheetOBJ setInitialText:initialText];
        [self presentViewController:tweetSheetOBJ animated:YES completion:nil];
    }
}

- (IBAction)infoButtonDidPress:(id)sender {
    [InfoPageViewController sharedInstance].startFromScript = NO;
    [self presentInfoViewController];
}

- (void)presentInfoViewController {
    UIViewController *infoViewController = [[UIStoryboard storyboardWithName:@"Info" bundle:nil] instantiateViewControllerWithIdentifier:@"InfoPageViewController"];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:infoViewController];
    popupController.cornerRadius = 10;
    if (NSClassFromString(@"UIBlurEffect")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:17] } forState:UIControlStateNormal];
    
    [InfoPageViewController sharedInstance].pageControl.currentPage = 1;
    
    [popupController presentInViewController:self];
}

- (void)toggleZeroStateLabel {
    
    //    // THIS LEADS TO BAD UX BC IF INTERNET/LOCATION FAILS THEN THE USER IS PRESENTED WITH A SWIPE L/R OPTION BUT CANNOT ACTUALLY SWIPE L/R
    //    // ALSO BAD UX BC IF CONGRESS LOADS FINE AND THEN INTERNET DROPS, THERE IS NO ZEROSTATE FOR STATELEG
    //    // ALSO ALSO BAD UX BC INFOVIEW HIDES THE ZEROSTATE LABEL
    //
    //    // Is there data already displayed?
    //    if (self.containerView.alpha == 1) {
    //        // do nothing
    //    }
    //
    //    // There is no data currently displayed
    //    else {
    //
    //        // If internet is good and location is good
    //        if ([AFNetworkReachabilityManager sharedManager].isReachable && [CLLocationManager authorizationStatus]== 4) {
    //            self.containerView.alpha = 1;
    //            self.zeroStateLabel.alpha = 0;
    //            //[[LocationService sharedInstance]startUpdatingLocation];
    //        }
    //        else {
    //
    //            // If internet is good but location is bad
    //            if ([AFNetworkReachabilityManager sharedManager].isReachable && [CLLocationManager authorizationStatus]== 0) {
    //                //self.zeroStateLabel.text = @"Could Not Determine Location";
    //            }
    //
    //            // If internet is bad but location is good
    //            else if (![AFNetworkReachabilityManager sharedManager].isReachable && [CLLocationManager authorizationStatus]== 4) {
    //                self.zeroStateLabel.text = @"No Internet Connection";
    //            }
    //
    //            // If internet is bad and location is bad
    //            else if (![AFNetworkReachabilityManager sharedManager].isReachable && [CLLocationManager authorizationStatus]== 4) {
    //                self.zeroStateLabel.text = @"Both Internet and Location Services Appear To Be Unavailable";
    //            }
    //            self.zeroStateLabel.alpha = 1;
    //        }
    //    }
}

- (void)updateInformationLabel:(NSNotification*)notification {
    //    if ([notification.name isEqualToString:@"com.alamofire.networking.operation.start"]) {
    //        self.informationLabel.text = @"loading...";
    //    }
    //    else {
    //        if ([self.legislatureLevel.text isEqualToString:@"Congress"]) {
    //            for(Congressperson *congressperson in [RepManager sharedInstance].listOfCongressmen) {
    //                NSString *districtNumber = [NSString stringWithFormat:@"%@",congressperson.districtNumber];
    //                if (![districtNumber isEqualToString:@"<null>"]) {
    //                    self.informationLabel.text = [NSString stringWithFormat:@"Congressional District %@-%@", congressperson.stateCode.uppercaseString, districtNumber];
    //                }
    //            }
    //        }
    //        else {
    //            if ([RepManager sharedInstance].listofStateLegislators.count > 0) {
    //                for(StateLegislator *stateLegislator in [RepManager sharedInstance].listofStateLegislators){
    //                    if ([stateLegislator.chamber isEqualToString:@"upper"]) {
    //                        self.stateUpperDistrictNumber = stateLegislator.districtNumber;
    //                    }
    //                    else {
    //                        self.stateLowerDistrictNumber = stateLegislator.districtNumber;
    //                    }
    //                    if (self.stateLowerDistrictNumber && self.stateUpperDistrictNumber) {
    //                        if ([stateLegislator.stateCode.uppercaseString isEqualToString:@"CA"] || [stateLegislator.stateCode.uppercaseString isEqualToString:@"NY"] || [stateLegislator.stateCode.uppercaseString isEqualToString:@"WI"] || [stateLegislator.stateCode.uppercaseString isEqualToString:@"NV"] || [stateLegislator.stateCode.uppercaseString isEqualToString:@"NJ"]) {
    //                            self.informationLabel.text = [NSString stringWithFormat:@"Assembly District: %@, Senate District: %@", self.stateLowerDistrictNumber, self.stateUpperDistrictNumber];
    //                        }
    //                        else {
    //                            self.informationLabel.text = [NSString stringWithFormat:@"%@ House District: %@, Senate District: %@",stateLegislator.stateCode.uppercaseString, self.stateLowerDistrictNumber, self.stateUpperDistrictNumber];
    //                        }
    //                    }
    //                }
    //            }
    //            else {
    //                self.informationLabel.text = @"Server error, try again";
    //            }
    //        }
    //    }
}

@end