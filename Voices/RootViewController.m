//
//  RootViewController.h
//  Voices
//
//  Created by John Bogil on 8/7/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "RootViewController.h"
#import "RepsNetworkManager.h"
#import "StateRepresentative.h"
#import "LocationService.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>
#import <STPopup/STPopup.h>
#import "FBShimmeringView.h"
#import "FBShimmeringLayer.h"
#import "RepsManager.h"
#import "ReportingManager.h"
#import "ScriptManager.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "ThankYouViewController.h"
#import "WebViewController.h"
#import "SearchResultsManager.h"
#import "SearchViewController.h"
#import "MoreViewController.h"

@interface RootViewController () <MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) NSString *representativeEmail;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;
@property (nonatomic, strong) UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *pageIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *federalButton;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak, nonatomic) IBOutlet UIButton *localButton;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSDictionary *buttonDictionary;
@property (strong, nonatomic) CTCallCenter *callCenter;
@property (nonatomic) double searchBarFontSize;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (weak, nonatomic) IBOutlet UIView *darkView;

@end

@implementation RootViewController

#pragma mark - Lifecycle methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self addObservers];
    [self setFont];
    [self setColors];
    [self configureSearchBar];
    [self configureDarkView];
    [self configureSearchResultsTableView];
//    [self setupCallCenterToPresentThankYou];
    
    self.buttonDictionary = @{@0 : self.federalButton, @1 : self.stateButton , @2 :self.localButton};
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    self.navigationController.navigationBar.hidden = YES;
    [self.searchResultsTableView reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.shadowView.frame = self.shimmeringView.frame;
    self.shadowView.layer.cornerRadius = self.searchView.layer.cornerRadius;
    
    self.shimmeringView.shimmering = NO;
    self.shimmeringView.contentView = self.searchView;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.shadowView.bounds];
    self.shadowView.layer.masksToBounds = NO;
    self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.shadowView.layer.shadowOpacity = 0.125f;
    self.shadowView.layer.shadowPath = shadowPath.CGPath;
    
    [self.infoButton setImageEdgeInsets:UIEdgeInsetsMake(11, 7, 11, 8)];
}

#pragma mark - Custom accessor methods

- (void)setColors {
    self.searchView.backgroundColor = [UIColor voicesOrange];
    self.infoButton.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:1];
    self.federalButton.tintColor = [UIColor voicesBlue];
    self.stateButton.tintColor = [UIColor voicesLightGray];
    self.localButton.tintColor = [UIColor voicesLightGray];
}

- (void)setFont {
    
    double screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone) {
        if (screenHeight == 568) {
            self.searchBarFontSize = 20;
        } else if (screenHeight == 667) {
            self.searchBarFontSize = 27;
        }
    }
    self.federalButton.titleLabel.font = [UIFont voicesBoldFontWithSize:25];
    self.stateButton.titleLabel.font = [UIFont voicesBoldFontWithSize:25];
    self.localButton.titleLabel.font = [UIFont voicesBoldFontWithSize:25];
}

- (void)updateTabForIndex:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath != indexPath) {
        
        UIButton *newButton = [self.buttonDictionary objectForKey:[NSNumber numberWithInteger:indexPath.item]];
        UIButton *lastButton = [self.buttonDictionary objectForKey:[NSNumber numberWithInteger:self.selectedIndexPath.item]];
        
        if (newButton == lastButton) {
            return;
        }
        
        [newButton.layer removeAllAnimations];
        [lastButton.layer removeAllAnimations];
        
        [UIView animateWithDuration:.25 animations:^{
            
            newButton.tintColor = [UIColor voicesBlue];
            lastButton.tintColor = [UIColor voicesLightGray];
            
        }];
        self.selectedIndexPath = indexPath;
    }
}

- (void)configureDarkView {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSearchResultsTableView)];
    [self.darkView addGestureRecognizer:tap];
    self.darkView.hidden = YES;
}

#pragma mark - Custom Search Bar Methods

- (void)configureSearchBar {
    
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:self.shadowView belowSubview:self.shimmeringView];
    
    [self.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.searchView.layer.cornerRadius = kButtonCornerRadius;
    self.searchTextField.delegate = self;
    self.searchTextField.backgroundColor = [UIColor searchBarBackground];
    self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Find Your Reps" attributes:@{NSFontAttributeName : [UIFont voicesFontWithSize:self.searchBarFontSize],NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.searchTextField.font = [UIFont voicesFontWithSize:self.searchBarFontSize];
    [self.searchTextField.layer setBorderWidth:2.0f];
    self.searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.searchTextField.layer.borderColor = [UIColor searchBarBackground].CGColor;
    self.searchTextField.layer.cornerRadius = kButtonCornerRadius;
    self.searchTextField.textColor = [UIColor whiteColor];
    self.searchTextField.tintColor = [UIColor voicesBlue];
    
    // Set the left view magnifiying glass
    [self.searchTextField setLeftViewMode:UITextFieldViewModeAlways];
    UIImageView *magnifyingGlass = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MagnifyingGlass"]];
    magnifyingGlass.frame = CGRectMake(0.0, 0.0, magnifyingGlass.image.size.width+20.0, magnifyingGlass.image.size.height);
    magnifyingGlass.contentMode = UIViewContentModeCenter;
    self.searchTextField.leftView = magnifyingGlass;
    
    // Create shadow
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:self.shadowView belowSubview:self.shimmeringView];
}

- (void)configureSearchResultsTableView {
    
    self.searchResultsTableView.hidden = YES;
    self.searchResultsTableView.layer.cornerRadius = kButtonCornerRadius;
    self.searchResultsTableView.delegate = [SearchResultsManager sharedInstance];
    self.searchResultsTableView.dataSource = [SearchResultsManager sharedInstance];
    self.searchResultsTableView.backgroundColor = [UIColor whiteColor];
    self.searchResultsTableView.backgroundView.backgroundColor = [UIColor whiteColor];
    [self.searchResultsTableView registerNib:[UINib nibWithNibName:@"ResultsTableViewCell" bundle:nil]forCellReuseIdentifier:@"ResultsTableViewCell"];
    [self.searchResultsTableView registerNib:[UINib nibWithNibName:@"cell" bundle:nil]forCellReuseIdentifier:@"cell"];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [SearchResultsManager sharedInstance].searchMethod = textField.text;
    self.searchTextField.text = [SearchResultsManager sharedInstance].searchMethod;
    
    [[LocationService sharedInstance]getCoordinatesFromSearchText:textField.text withCompletion:^(CLLocation *locationResults) {
        
        [[RepsManager sharedInstance]createFederalRepresentativesFromLocation:locationResults WithCompletion:^{
            NSLog(@"%@", locationResults);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
        
        [[RepsManager sharedInstance]createStateRepresentativesFromLocation:locationResults WithCompletion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
        
        [[RepsManager sharedInstance]createNYCRepsFromLocation:locationResults];
        
    } onError:^(NSError *googleMapsError) {
        NSLog(@"%@", [googleMapsError localizedDescription]);
    }];
    
    [self hideSearchResultsTableView];
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.darkView.hidden = NO;
    
    self.searchResultsTableView.hidden = NO;
    
    self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Address" attributes:@{NSFontAttributeName : [UIFont voicesFontWithSize:self.searchBarFontSize], NSForegroundColorAttributeName: [UIColor whiteColor]}];
    // Set the clear button
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [clearButton setImage:[UIImage imageNamed:@"ClearButton"] forState:UIControlStateNormal];
    [clearButton setImage:[UIImage imageNamed:@"ClearButton"] forState:UIControlStateHighlighted];
    [clearButton addTarget:self action:@selector(clearSearchBar) forControlEvents:UIControlEventTouchUpInside];
    self.searchTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.searchTextField.rightView = clearButton;
}

- (void)textFieldDidChange:(UITextField *)textfield {
    if (textfield.text.length > 0) {
        [[SearchResultsManager sharedInstance] placeAutocomplete:textfield.text onSuccess:^{
            [self.searchResultsTableView reloadData];
        }];
    }
    else {
        [[SearchResultsManager sharedInstance] clearSearchResults];
        [self.searchResultsTableView reloadData];
    }
}

- (void)clearSearchBar {
    [[SearchResultsManager sharedInstance] clearSearchResults];
    [self.searchResultsTableView reloadData];
    self.searchTextField.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.searchTextField resignFirstResponder];
}

- (void)onKeyboardHide {
    self.darkView.hidden = YES;
    self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Find Your Reps" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont voicesFontWithSize:self.searchBarFontSize]}];
    self.searchResultsTableView.hidden = YES;
}

#pragma mark - NSNotifications

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEmailViewController:) name:@"presentEmailVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callStateDidChange:) name:@"CTCallStateDidChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTweetComposer:)name:@"presentTweetComposer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentInfoViewController)name:@"presentInfoViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSearchText) name:@"refreshSearchText" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustToStatusBarChange) name:@"thankYouViewControllerDismissed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingOperationDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidSuspendNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentWebViewController:) name:@"presentWebView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPageIndicator:) name:@"actionPageJump" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentPullToRefreshAlert) name:@"presentPullToRefreshAlert" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSearchViewController) name:@"presentSearchViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSearchResultsTableView) name:@"hideSearchResultsTableView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSearchText) name:@"refreshSearchBarPullToRefresh" object:nil];

}

- (void)adjustToStatusBarChange {
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    for (UIView *view in window.subviews) {
        view.frame = window.bounds;
    }
}

- (void)keyboardDidShow:(NSNotification *)note {
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSearchResultsTableView)];
}

#pragma mark - FB Shimmer methods

- (void)toggleShimmerOn {
    self.shimmeringView.shimmering = YES;
}

- (void)toggleShimmerOff {
    [self.shimmeringView performSelector:@selector(setShimmering:)];
    self.shimmeringView.shimmering = NO;
}

#pragma mark - Presentation Controllers

- (void)presentEmailViewController:(NSNotification*)notification {
    self.representativeEmail = [notification object];
    if(self.representativeEmail != nil){
        [self selectMailApp];
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"A message is required" message:@"Please enter a message" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)selectMailApp {
    // try Mail app
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        //        [mailViewController setSubject:@"Subject Goes Here."];
        //        [mailViewController setMessageBody:@"Your message goes here." isHTML:NO];
        [mailViewController setToRecipients:@[self.representativeEmail]];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else { // try Gmail
        NSString *gmailURL = [NSString stringWithFormat:@"googlegmail:///co?to=%@", self.representativeEmail];
        if ([[UIApplication sharedApplication]
             canOpenURL:[NSURL URLWithString:gmailURL]]){
            [[UIApplication sharedApplication]  openURL: [NSURL URLWithString:gmailURL]];
        }
        else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No mail accounts" message:@"Please set up a Mail account or a Gmail account in order to send email." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    NSString *title;
    NSString *message;
    
    switch (result) {
        case MFMailComposeResultCancelled:
        {
            break;
        }
        case MFMailComposeResultSaved:
            title = @"Draft Saved";
            message = @"Composed Mail is saved in draft.";
            break;
        case MFMailComposeResultSent:
        {
            
            title = @"Success";
            [[ReportingManager sharedInstance]reportEvent:kEMAIL_EVENT eventFocus:self.representativeEmail eventData:[ScriptManager sharedInstance].lastAction.key];
            message = @"";
            break;
        }
        case MFMailComposeResultFailed:
            title = @"Failed";
            message = @"Sorry! Failed to send.";
            break;
        default:
            break;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentWebViewController:(NSNotification *)notifiaction {
    
    NSURL *url = notifiaction.object[@"contactFormURL"];
    NSString *fullName = notifiaction.object[@"fullName"];
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    WebViewController *webViewController = (WebViewController *)[repsSB instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = url;
    webViewController.title = fullName;
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)presentTweetComposer:(NSNotification*)notification {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *initialText = [NSString stringWithFormat:@".@%@", [notification.userInfo objectForKey:@"accountName"]];
        [tweetSheetOBJ setInitialText:initialText];
        [tweetSheetOBJ setCompletionHandler:^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Twitter Post Canceled");
                    
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Twitter Post Sucessful");
                    [[ReportingManager sharedInstance]reportEvent:kTWEET_EVENT eventFocus:[notification.userInfo objectForKey:@"accountName"] eventData:[ScriptManager sharedInstance].lastAction.key];
                    
                    break;
                default:
                    break;
            }
        }];
        [self presentViewController:tweetSheetOBJ animated:YES completion:nil];
    }
}

- (void)presentInfoViewController {
    
    [self setupAndPresentSTPopupControllerWithNibNamed:@"NewInfo" inViewController:self];
}

- (void)presentScriptDialog {
    
    [self setupAndPresentSTPopupControllerWithNibNamed:@"ScriptDialog" inViewController:self];
}

- (void)setupAndPresentSTPopupControllerWithNibNamed:(NSString *) name inViewController:(UIViewController *)viewController  {
    
    UIViewController *infoViewController = (UIViewController *)[[[NSBundle mainBundle] loadNibNamed:name owner:viewController options:nil] objectAtIndex:0];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:infoViewController];
    popupController.containerView.layer.cornerRadius = 10;
    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor]; // This is the only OK "orangeColor", for now
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:23], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[STPopupNavigationBar class]]] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:19] } forState:UIControlStateNormal];
    [popupController presentInViewController:viewController];
}

- (void)presentPullToRefreshAlert {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Reps For Current Location"
                                message:@"Please enable location services when asked."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *button0 = [UIAlertAction
                              actionWithTitle:@"Not now"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
    UIAlertAction *button1 = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [[LocationService sharedInstance]startUpdatingLocation];

                                      [self refreshSearchText];
 
                              }];
    [alert addAction:button0];
    [alert addAction:button1];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentSearchViewController {
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    SearchViewController *searchViewController = (SearchViewController *)[repsSB instantiateViewControllerWithIdentifier:@"SearchViewController"];
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (homeAddress.length > 0) {
        searchViewController.title = @"Edit Home Address";
    }
    else {
        searchViewController.title = @"Add Home Address";
    }
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)hideSearchResultsTableView {
    
    self.searchResultsTableView.hidden = YES;
    self.darkView.hidden = YES;
    self.searchTextField.text = [SearchResultsManager sharedInstance].searchMethod;
    [self.searchTextField resignFirstResponder];
    [self.darkView removeGestureRecognizer:self.tap];
}


#pragma mark Call Center methods
- (void)setupCallCenterToPresentThankYou {
    // __weak RootViewController *weakself = self;
//    self.callCenter = [[CTCallCenter alloc] init];
//    self.callCenter.callEventHandler = ^void(CTCall *call) {
//        if (call.callState == CTCallStateDisconnected) {
//            dispatch_async(dispatch_get_main_queue(), ^{
                // [weakself setupAndPresentSTPopupControllerWithNibNamed:@"ThankYouViewController" inViewController:weakself];
                //Announce that we've had a state change in CallCenter
                //                NSDictionary *dict = [NSDictionary dictionaryWithObject:call.callState forKey:@"callState"]; [[NSNotificationCenter defaultCenter] postNotificationName:@"CTCallStateDidChange" object:nil userInfo:dict];
//            });
//        }
//    };
}

- (void)callStateDidChange:(NSNotification *)notification {
    
    //Log the notification
    NSLog(@"Notification : %@", notification);
    
    NSString *callInfo = [[notification userInfo] objectForKey:@"callState"];
    if([callInfo isEqualToString: CTCallStateDialing]) {
        
        //The call state, before connection is established, when the user initiates the call.
        NSLog(@"****** call is dialing ******");
    }
    if([callInfo isEqualToString: CTCallStateIncoming]) {
        
        //The call state, before connection is established, when a call is incoming but not yet answered by the user.
        NSLog(@"***** call is incoming ******");
    }
    if([callInfo isEqualToString: CTCallStateConnected]) {
        
        //The call state when the call is fully established for all parties involved.
        NSLog(@"***** call connected *****");
        
    }
    if([callInfo isEqualToString: CTCallStateDisconnected]) {
        
        //the call state has ended
        NSLog(@"***** call ended *****");
    }
}

#pragma mark - IBActions

- (IBAction)infoButtonDidPress:(id)sender {
    [self presentInfoViewController];
    
//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"More" bundle:nil];
//    MoreViewController* moreVC = [storyboard instantiateViewControllerWithIdentifier:@"more"];
//    [moreVC.navigationItem setTitle:@"More"];
//    [self.navigationController pushViewController:moreVC animated:YES];
}

- (IBAction)federalPageButtonDidPress:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"jumpPage" object:@0];
}

- (IBAction)statePageButtonDidPress:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"jumpPage" object:@1];
}

- (IBAction)localPageButtonDidPress:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"jumpPage" object:@2];
}

- (void)setPageIndicator:(NSNotification *)notification {
    long int pageNumber = [notification.object integerValue];
    if (pageNumber == 0) {
        [self.federalButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else if (pageNumber == 1) {
        [self.stateButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else if (pageNumber == 2) {
        [self.localButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    [self presentScriptDialog];
    
}

- (void)refreshSearchText {
    self.searchTextField.attributedText = nil;
    self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Current Location" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont voicesFontWithSize:self.searchBarFontSize]}];
}

@end
