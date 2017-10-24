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
#import "LocationManager.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>
#import <STPopup/STPopup.h>
#import "RepsManager.h"
#import "ReportingManager.h"
#import "ScriptManager.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "WebViewController.h"
#import "AddAddressViewController.h"
#import "MoreViewController.h"

@interface RootViewController () <MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) NSString *representativeEmail;
@property (strong, nonatomic) CTCallCenter *callCenter;
@property (weak, nonatomic) IBOutlet UILabel *findRepsLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIView *singleLineView;

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
        [[RepsManager sharedInstance] fetchRepsForAddress:homeAddress];
    }
}

- (void)configureSearchBar {
    
    self.findRepsLabel.font = [UIFont voicesBoldFontWithSize:40];
    self.findRepsLabel.text = @"My Reps";
    self.findRepsLabel.adjustsFontSizeToFitWidth = YES;
    self.moreButton.tintColor = [UIColor blackColor];
    [self.moreButton setImage:[UIImage imageNamed:@"femaleUser"] forState:UIControlStateNormal];
    self.moreButton.backgroundColor = [UIColor clearColor];
}

#pragma mark - NSNotifications

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEmailViewController:) name:@"presentEmailVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callStateDidChange:) name:@"CTCallStateDidChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTweetComposer:)name:@"presentTweetComposer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentInfoViewController)name:@"presentInfoViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentWebViewController:) name:@"presentWebView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentPullToRefreshAlert) name:@"presentPullToRefreshAlert" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAddAddressViewControllerInRootVC) name:@"presentAddAddressViewControllerInRootVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentScriptDialog) name:@"presentScriptView" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeAlertView) name:@"closeAlertView" object:nil];
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
    webViewController.hidesBottomBarWhenPushed = YES; // I would actually set this in WebViewController's viewDidLoad method
    // Push on to the current tab bar's nav controller.
    UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
    navController.navigationBar.hidden = NO;
    [navController pushViewController:webViewController animated:YES];
}

- (void)presentTweetComposer:(NSNotification*)notification {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=.%@",[notification.userInfo objectForKey:@"accountName"] ]];
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    WebViewController *webViewController = (WebViewController *)[repsSB instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = url;
    webViewController.title = [notification.userInfo objectForKey:@"accountName"];
    webViewController.hidesBottomBarWhenPushed = YES; // I would actually set this in WebViewController's viewDidLoad method
    // Push on to the current tab bar's nav controller.
    UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
    navController.navigationBar.hidden = NO;
    [navController pushViewController:webViewController animated:YES];
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
                                  [[LocationManager sharedInstance]startUpdatingLocation];
                                  
                              }];
    [alert addAction:button0];
    [alert addAction:button1];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentAddAddressViewControllerInRootVC {
    
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    AddAddressViewController *addAddressViewController = (AddAddressViewController *)[repsSB instantiateViewControllerWithIdentifier:@"AddAddressViewController"];
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (homeAddress.length > 0) {
        addAddressViewController.title = @"Edit Home Address";
    }
    else {
        addAddressViewController.title = @"Add Home Address";
    }
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:addAddressViewController animated:YES];
}

- (void)closeAlertView {
    
    [self dismissViewControllerAnimated: YES completion: nil];
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

- (IBAction)moreButtonDidPress:(id)sender {
    
    UIStoryboard *moreSB = [UIStoryboard storyboardWithName:@"More" bundle: nil];
    MoreViewController *moreViewController = (MoreViewController *)[moreSB instantiateViewControllerWithIdentifier:@"MoreViewController"];
    moreViewController.title = @"More";
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:moreViewController animated:YES];
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
