//
//  RootViewController.h
//  Voices
//
//  Created by John Bogil on 8/7/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "RootViewController.h"
#import "NetworkManager.h"
#import "StateRepresentative.h"
#import "LocationService.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>
#import <STPopup/STPopup.h>
#import "FBShimmeringView.h"
#import "FBShimmeringLayer.h"
#import "RepsManager.h"

@interface RootViewController () <MFMailComposeViewControllerDelegate, UITextFieldDelegate>

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
@property int didLayoutCounter;
//@property (strong, nonatomic) UIView *tapView;

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
    
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:self.shadowView belowSubview:self.shimmeringView];
    
    [self addObservers];
    [self setFont];
    [self setColors];
    [self configureSearchBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPageIndicator:) name:@"actionPageJump" object:nil];
    
    self.buttonDictionary = @{ @0 : self.federalButton, @1 : self.stateButton , @2 :self.localButton};
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
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
    
//    Make the hitbox twice the size of the infoButtons Image
    if (self.didLayoutCounter < 2) {
        CGRect initialFrame = self.infoButton.frame;
        CGFloat initialHeight = initialFrame.size.height/2;
        CGFloat initialWidth = initialFrame.size.width/2;
        self.infoButton.frame = CGRectMake(initialFrame.origin.x - initialWidth, initialFrame.origin.y - initialHeight, initialFrame.size.width * 2, initialFrame.size.height * 2);
        self.infoButton.contentEdgeInsets = UIEdgeInsetsMake(initialHeight, initialWidth, initialHeight, initialWidth);
        [self.infoButton layoutSubviews];
        self.didLayoutCounter++;
    }
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

- (void)updateTabForIndex:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath != indexPath) {
        
        UIButton *newButton = [self.buttonDictionary objectForKey:[NSNumber numberWithInteger:indexPath.item]];
        UIButton *lastButton = [self.buttonDictionary objectForKey:[NSNumber numberWithInteger:self.selectedIndexPath.item]];
        
        [newButton.layer removeAllAnimations];
        [lastButton.layer removeAllAnimations];
        
        [UIView animateWithDuration:.25 animations:^{
            
            newButton.tintColor = [UIColor voicesBlue];
            lastButton.tintColor = [UIColor voicesLightGray];
            
        }];
        self.selectedIndexPath = indexPath;
    }
}

#pragma mark - Custom Search Bar Methods

- (void)configureSearchBar {
    
    self.searchView.layer.cornerRadius = kButtonCornerRadius;
    
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
    
    // Create shadow
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:self.shadowView belowSubview:self.shimmeringView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    //    if([self.tapView respondsToSelector:@selector(removeFromSuperview)]){
    //        [self.tapView removeFromSuperview];
    //    }
    
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
    
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    // Set the clear button
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [clearButton setImage:[UIImage imageNamed:@"ClearButton"] forState:UIControlStateNormal];
    [clearButton setImage:[UIImage imageNamed:@"ClearButton"] forState:UIControlStateHighlighted];
    [clearButton addTarget:self action:@selector(clearSearchBar) forControlEvents:UIControlEventTouchUpInside];
    self.searchTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.searchTextField.rightView = clearButton;
}

- (void)clearSearchBar {
    self.searchTextField.text = @"";
    [self.searchTextField resignFirstResponder];
    self.searchTextField.rightViewMode = UITextFieldViewModeNever;
}

#pragma mark - NSNotifications

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEmailViewController:) name:@"presentEmailVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTweetComposer:)name:@"presentTweetComposer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentInfoViewController)name:@"presentInfoViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSearchText) name:@"refreshSearchText" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingOperationDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidSuspendNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidCompleteNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)note {
    //    self.tapView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    //    self.tapView.backgroundColor = [UIColor clearColor];
    //    [self.view addSubview:self.tapView];
    //    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    //    [self.tapView addGestureRecognizer:self.tap];
}


- (void)dismissKeyboard {
    [self.searchTextField resignFirstResponder];
    [self.containerView removeGestureRecognizer:self.tap];
    //[self.tapView removeFromSuperview];
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
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[STPopupNavigationBar class]]] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:19] } forState:UIControlStateNormal];
    [popupController presentInViewController:self];
}

#pragma mark - IBActions

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
}

- (void)refreshSearchText {
    self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Current Location" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

@end
