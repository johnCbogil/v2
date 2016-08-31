//
//  RootViewController.h
//  Voices
//
//  Created by John Bogil on 8/7/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "RootViewController.h"
#import "NetworkManager.h"
#import "RepManager.h"
#import "StateRepresentative.h"
#import "CacheManager.h"
#import "PageViewController.h"
#import "LocationService.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>
#import <STPopup/STPopup.h>
#import "FBShimmeringView.h"
#import "FBShimmeringLayer.h"
#import "SMPageControl.h"

@interface RootViewController () <MFMailComposeViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) PageViewController *pageVC;
@property (strong, nonatomic) NSString *representativeEmail;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;
@property (nonatomic, strong) UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *pageIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *federalButton;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak, nonatomic) IBOutlet UIButton *localButton;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

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
    
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:self.shadowView belowSubview:self.shimmeringView];
    
    [self addObservers];
    [self setFont];
    [self setColors];
    [self configureSearchBar];
}

- (void)configureSearchBar {
    self.searchTextField.delegate = self;
    self.searchTextField.backgroundColor = [UIColor searchBarBackground];
    self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search By Address" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
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
    
    // Set the clear button
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [clearButton setImage:[UIImage imageNamed:@"ClearButton"] forState:UIControlStateNormal];
    [clearButton setImage:[UIImage imageNamed:@"ClearButton"] forState:UIControlStateHighlighted];
    [clearButton addTarget:self action:@selector(clearSearchBar) forControlEvents:UIControlEventTouchUpInside];
    self.searchTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.searchTextField.rightView = clearButton;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    for (id vc in self.childViewControllers) {
        if ([vc isKindOfClass:[UIPageViewController class]]) {
            self.pageVC = vc;
        }
    }
    
    [[LocationService sharedInstance]getCoordinatesFromSearchText:textField.text withCompletion:^(CLLocation *locationResults) {
        
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
    
    
    return NO;
}

- (void)clearSearchBar {
   self.searchTextField.text = @"";
   [self.searchTextField resignFirstResponder];
   self.searchTextField.rightViewMode = UITextFieldViewModeNever;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Create a shadow. Fake shadow view is white and below the shimmerview.
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
}

#pragma mark - Custom accessor methods

- (void)setColors {
    self.searchView.backgroundColor = [UIColor voicesOrange];
//    self.magnifyingGlassImageView.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:1];
    self.infoButton.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:1];
    self.federalButton.tintColor = [UIColor voicesBlue];
    self.stateButton.tintColor = [UIColor voicesLightGray];
    self.localButton.tintColor = [UIColor voicesLightGray];
}

- (void)setFont {
    self.federalButton.titleLabel.font = [UIFont voicesBoldFontWithSize:20];
    self.stateButton.titleLabel.font = [UIFont voicesBoldFontWithSize:20];
    self.localButton.titleLabel.font = [UIFont voicesBoldFontWithSize:20];
}

#pragma mark - NSNotifications

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage:) name:@"changePage" object:nil];
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
}

- (void)dismissKeyboard {
    [self.searchTextField resignFirstResponder];
    [self.containerView removeGestureRecognizer:self.tap];
}

// TODO: CHANGE THIS TO DELEGATE PATTERN
- (void)changePage:(NSNotification *)notification {
    NSDictionary* userInfo = notification.object;
    NSString *currentPageString = userInfo[@"currentPage"];
    if (currentPageString.length > 0) {
        //        self.legislatureLevel.text = currentPageString;
    }
    
    [UIView animateWithDuration:.15 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    // TODO: THIS IS NOT DRY
    if ([currentPageString isEqualToString:@"Federal"]) {
        self.federalButton.tintColor = [UIColor voicesBlue];
        self.stateButton.tintColor = [UIColor voicesLightGray];
        self.localButton.tintColor = [UIColor voicesLightGray];
    }
    else if ([currentPageString isEqualToString:@"State"]) {
        self.federalButton.tintColor = [UIColor voicesLightGray];
        self.stateButton.tintColor = [UIColor voicesBlue];
        self.localButton.tintColor = [UIColor voicesLightGray];
    }
    else {
        self.federalButton.tintColor = [UIColor voicesLightGray];
        self.stateButton.tintColor = [UIColor voicesLightGray];
        self.localButton.tintColor = [UIColor voicesBlue];
    }
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
        [tweetSheetOBJ setCompletionHandler:^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Twitter Post Canceled");
                    
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Twitter Post Sucessful");
                    break;
                default:
                    break;
            }
        }];
        [self presentViewController:tweetSheetOBJ animated:YES completion:nil];
    }
}

- (void)presentInfoViewController {
    UIViewController *infoViewController = (UIViewController *)[[[NSBundle mainBundle] loadNibNamed:@"Info" owner:self options:nil] objectAtIndex:0];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:infoViewController];
    popupController.containerView.layer.cornerRadius = 10;
    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor]; // This is the only OK "orangeColor", for now
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:23], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:19] } forState:UIControlStateNormal];
    [popupController presentInViewController:self];
}

#pragma mark - IBActions

- (IBAction)infoButtonDidPress:(id)sender {
    [self presentInfoViewController];
}

- (IBAction)federalPageButtonDidPress:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"jumpPage" object:@0];
    self.federalButton.tintColor = [UIColor voicesBlue];
    self.stateButton.tintColor = [UIColor voicesLightGray];
    self.localButton.tintColor = [UIColor voicesLightGray];
}
- (IBAction)statePageButtonDidPress:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"jumpPage" object:@1];
    self.federalButton.tintColor = [UIColor voicesLightGray];
    self.stateButton.tintColor = [UIColor voicesBlue];
    self.localButton.tintColor = [UIColor voicesLightGray];
}
- (IBAction)localPageButtonDidPress:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"jumpPage" object:@2];
    self.federalButton.tintColor = [UIColor voicesLightGray];
    self.stateButton.tintColor = [UIColor voicesLightGray];
    self.localButton.tintColor = [UIColor voicesBlue];
}

@end
