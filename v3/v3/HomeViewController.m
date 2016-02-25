//
//  HomeViewController.m
//  v3
//
//  Created by John Bogil on 8/7/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "HomeViewController.h"
#import "NetworkManager.h"
#import "RepManager.h"
#import "UIFont+voicesFont.h"
#import "StateLegislator.h"
#import "CacheManager.h"
#import "UIColor+voicesOrange.h"
#import "PageViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "LocationService.h"
#import <Social/Social.h>
#import <STPopup/STPopup.h>
//#import "FBShimmeringView.h"
//#import "FBShimmeringLayer.h"

@interface HomeViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *legislatureLevel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIImageView *magnifyingGlass;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewWidthConstraint;
@property (assign, nonatomic) CGFloat searchViewDefaultWidth;
@property (strong, nonatomic) NSString *stateLowerDistrictNumber;
@property (strong, nonatomic) NSString *stateUpperDistrictNumber;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UILabel *callToActionLabel;
@property (strong, nonatomic) PageViewController *pageVC;
//@property (strong, nonatomic) FBShimmeringView *shimmeringView;
//@property (weak, nonatomic) IBOutlet UIView *shimmer;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[CacheManager sharedInstance] checkCacheForRepresentative:@"cachedCongresspersons"];
    [self addObservers];
    [self setFont];
    [self setColors];
    [self prepareSearchBar];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setColors {
    self.searchView.backgroundColor = [UIColor voicesOrange];
    self.infoButton.tintColor = [[UIColor blackColor]colorWithAlphaComponent:.5];
    self.pageControl.pageIndicatorTintColor = [[UIColor blackColor]colorWithAlphaComponent:.2];
}
- (void)setFont {
    self.callToActionLabel.font = [UIFont voicesFontWithSize:24];
    self.legislatureLevel.font = [UIFont voicesFontWithSize:27];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage:) name:@"changePage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEmailViewController:) name:@"presentEmailVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTweetComposer:)name:@"presentTweetComposer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentInfoViewController)name:@"presentInfoViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInformationLabel:)name:@"updateInformationLabel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInformationLabel:) name:AFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInformationLabel:) name:AFNetworkingOperationDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInformationLabel:) name:AFNetworkingTaskDidSuspendNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)note {
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
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
    
    self.searchViewDefaultWidth = self.searchViewWidthConstraint.constant;
    
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
    
    [[LocationService sharedInstance]getCoordinatesFromSearchText:searchBar.text withCompletion:^(CLLocation *locationResults) {
        if ([self.legislatureLevel.text isEqualToString:@"Congress"]) {
            [[RepManager sharedInstance]createCongressmenFromLocation:locationResults WithCompletion:^{
                NSLog(@"%@", locationResults);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
        else if ([self.legislatureLevel.text isEqualToString:@"State Legislators"]){
                [[RepManager sharedInstance]createStateLegislatorsFromLocation:locationResults WithCompletion:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
                } onError:^(NSError *error) {
                    [error localizedDescription];
                }];
        }
        else if ([self.legislatureLevel.text isEqualToString:@"NYC Council"]){
//            [[RepManager sharedInstance]createNYCRepresentativesFromLocation:results WithCompletion:^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
//            } onError:^(NSError *error) {
//                [error localizedDescription];
//            }];
            [[RepManager sharedInstance]createNYCRepsFromLocation:locationResults];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
        }
    } onError:^(NSError *googleMapsError) {
        NSLog(@"%@", [googleMapsError localizedDescription]);
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
    else if ([[userInfo valueForKey:@"currentPage"] isEqualToString:@"State Legislators"]) {
        self.pageControl.currentPage = 1;
    }
    else {
        self.pageControl.currentPage = 2;
    }
    [self updateInformationLabel:nil];
}


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
    switch (result) {
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
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *initialText = [NSString stringWithFormat:@".@%@", [notification.userInfo objectForKey:@"accountName"]];
        [tweetSheetOBJ setInitialText:initialText];
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

- (void)updateInformationLabel:(NSNotification*)notification {
    if ([notification.name isEqualToString:@"com.alamofire.networking.operation.start"]) {
        self.callToActionLabel.text = @"loading...";
    }
    else {
        self.callToActionLabel.text = @"Make your voice heard.";
    }
}

#pragma mark - FB Shimmer methods
// Save for later

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // THIS NEEDS TO HAPPEN HERE BC CONSTRAINTS HAVE NOT APPEARED UNTIL VDA
    //   [self prepareShimmer];
}

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

@end