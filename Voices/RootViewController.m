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
#import "RepsManager.h"
#import "ReportingManager.h"
#import "ScriptManager.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "ThankYouViewController.h"
#import "WebViewController.h"
#import "SearchViewController.h"
#import "MoreViewController.h"

@interface RootViewController () <MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) NSString *representativeEmail;
@property (strong, nonatomic) CTCallCenter *callCenter;
@property (weak, nonatomic) IBOutlet UILabel *findRepsLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

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
    [self configureSearchBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    self.navigationController.navigationBar.hidden = YES;
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]valueForKey:kHomeAddress];
    if (homeAddress.length && ![RepsManager sharedInstance].fedReps.count) {
        [self fetchRepsForAddress:homeAddress];
    }
}

- (void)configureSearchBar {
    
    self.findRepsLabel.font = [UIFont voicesBoldFontWithSize:36];
    self.findRepsLabel.text = @"Contact Reps";
    self.searchButton.tintColor = [UIColor blackColor];
    self.moreButton.tintColor = [UIColor blackColor];
}

- (void)fetchRepsForAddress:(NSString *)address {
    
    if (address.length) {
        [[LocationService sharedInstance]getCoordinatesFromSearchText:address withCompletion:^(CLLocation *locationResults) {
            
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
    }
}

#pragma mark - NSNotifications

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEmailViewController:) name:@"presentEmailVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callStateDidChange:) name:@"CTCallStateDidChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTweetComposer:)name:@"presentTweetComposer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentInfoViewController)name:@"presentInfoViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentWebViewController:) name:@"presentWebView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentPullToRefreshAlert) name:@"presentPullToRefreshAlert" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSearchViewController) name:@"presentSearchViewController" object:nil];
}

#pragma mark - Presentation Controllers

- (void)presentEmailViewController:(NSNotification*)notification {
    
    self.representativeEmail = [notification object];
    if([self.representativeEmail isKindOfClass:[NSString class]] && self.representativeEmail.length){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Email Rep" message:@"Would you like to email this rep?" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Not now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        [self selectMailApp];
                                    }]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
        
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This rep hasn't given us their email address, try calling instead." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Good Idea" style:UIAlertActionStyleDefault handler:nil]];
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
                    
                    break;
                case SLComposeViewControllerResultDone:
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
                                  
                              }];
    [alert addAction:button0];
    [alert addAction:button1];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentSearchViewController {
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    SearchViewController *searchViewController = (SearchViewController *)[repsSB instantiateViewControllerWithIdentifier:@"SearchViewController"];
    searchViewController.isHomeAddressVC = YES;
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
    
    NSString *callInfo = [[notification userInfo] objectForKey:@"callState"];
    if([callInfo isEqualToString: CTCallStateDialing]) {
        
        //The call state, before connection is established, when the user initiates the call.
    }
    if([callInfo isEqualToString: CTCallStateIncoming]) {
        
        //The call state, before connection is established, when a call is incoming but not yet answered by the user.
    }
    if([callInfo isEqualToString: CTCallStateConnected]) {
        
        //The call state when the call is fully established for all parties involved.
    }
    if([callInfo isEqualToString: CTCallStateDisconnected]) {
        
        //the call state has ended
    }
}

#pragma mark - IBActions

- (IBAction)searchButtonDidPress:(id)sender {
    
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    SearchViewController *searchViewController = (SearchViewController *)[repsSB instantiateViewControllerWithIdentifier:@"SearchViewController"];
    searchViewController.title = @"Find reps by address";
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (IBAction)moreButtonDidPress:(id)sender {
    
    [self presentInfoViewController];
}

- (IBAction)infoButtonDidPress:(id)sender {
    [self presentInfoViewController];
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


@end
