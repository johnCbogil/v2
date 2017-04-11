//
//  ActionDetailViewController.m
//  Voices
//
//  Created by John Bogil on 3/20/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailViewController.h"
#import "ActionDetailTopTableViewCell.h"
#import "ActionDetailMiddleTableViewCell.h"
#import "ActionDetailBottomTableViewCell.h"
#import "SearchViewController.h"
#import "LocationService.h"
#import "RepsManager.h"
#import "ReportingManager.h"
#import "ScriptManager.h"
#import "WebViewController.h"
#import "STPopupController.h"
#import <Social/Social.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <MessageUI/MFMailComposeViewController.h>

@import UserNotifications;

@interface ActionDetailViewController () <UITableViewDelegate, UITableViewDataSource, SelectRepDelegate, UITextViewDelegate, UNUserNotificationCenterDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) Representative *selectedRep;
@property (nonatomic) CTCallCenter *callCenter;

@end

@implementation ActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerCallStateNotification];
    [ScriptManager sharedInstance].lastAction = self.action;
    self.title = self.group.name;
    [self configureTableview];
    [self configureHomeButton];
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (homeAddress) {
        [self fetchRepsForHomeAddress:homeAddress];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSearchViewController) name:@"presentSearchViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCaller) name:@"presentCaller" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEmailComposer) name:@"presentEmailComposer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTweetComposerInActionDetail) name:@"presentTweetComposerInActionDetail" object:nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (homeAddress) {
        [self fetchRepsForHomeAddress:homeAddress];
    }
}

- (void)configureTableview {
    
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 300;
    self.tableview.separatorColor = [UIColor clearColor];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview registerNib:[UINib nibWithNibName:@"ActionDetailTopTableViewCell" bundle:nil]forCellReuseIdentifier:@"ActionDetailTopTableViewCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"ActionDetailMiddleTableViewCell" bundle:nil]forCellReuseIdentifier:@"ActionDetailMiddleTableViewCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"ActionDetailBottomTableViewCell" bundle:nil]forCellReuseIdentifier:@"ActionDetailBottomTableViewCell"];
}

- (void)configureHomeButton {
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"HomeEdit"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(presentSearchViewController)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 25, 25)];
    button.tintColor = [UIColor voicesOrange];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
}

- (void)fetchRepsForHomeAddress:(NSString *)address {
    
    [[LocationService sharedInstance]getCoordinatesFromSearchText:address withCompletion:^(CLLocation *locationResults) {
        
        if (self.action.level == 0) {
            [[RepsManager sharedInstance]createFederalRepresentativesFromLocation:locationResults WithCompletion:^{
                NSLog(@"%@", locationResults);
                [self.tableview reloadData];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
        else if (self.action.level == 1) {
            [[RepsManager sharedInstance]createStateRepresentativesFromLocation:locationResults WithCompletion:^{
                [self.tableview reloadData];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
        else if (self.action.level == 2) {
            [[RepsManager sharedInstance]createNYCRepsFromLocation:locationResults];
            [self.tableview reloadData];
        }
    } onError:^(NSError *googleMapsError) {
        NSLog(@"%@", [googleMapsError localizedDescription]);
    }];
    [self.tableview reloadData];
}

#pragma mark - UITableView Delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        ActionDetailTopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionDetailTopTableViewCell"];
        [cell initWithAction:self.action andGroup:self.group];
        return cell;
    }
    else if (indexPath.row == 1) {
        ActionDetailMiddleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionDetailMiddleTableViewCell"];
        return cell;
    }
    else {
        ActionDetailBottomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionDetailBottomTableViewCell"];
        cell.delegate = self;
        cell.descriptionTextView.delegate = self;
        [cell initWithAction:self.action];
        return cell;
    }
}

- (void)selectRep:(Representative *)rep {
    NSLog(@"%@",rep.fullName);
    self.selectedRep = rep;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.tableview beginUpdates];
    [self.tableview endUpdates];
}

#pragma mark - Presentation Controllers

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

- (void)presentCaller {
    
    if (self.selectedRep.phone.length) {
        NSString *confirmCallMessage = @"A call script will appear when you begin calling. Would you like to preview it or begin calling?";
        NSString *title;
        if (self.selectedRep.nickname != nil && ![self.selectedRep.nickname isEqual:[NSNull null]]) {
            title =  [NSString stringWithFormat:@"Call %@", self.selectedRep.nickname];
        }
        else {
            title =  [NSString stringWithFormat:@"Call %@ %@", self.selectedRep.firstName, self.selectedRep.lastName];
        }
        
        UIAlertController *confirmCallAlertController = [UIAlertController alertControllerWithTitle:title  message:confirmCallMessage preferredStyle:UIAlertControllerStyleAlert];
        [confirmCallAlertController addAction:[UIAlertAction actionWithTitle:@"Preview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

            [self presentScriptView];
            
        }]];
        [confirmCallAlertController addAction:[UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [[ReportingManager sharedInstance] reportEvent:kCALL_EVENT eventFocus:self.selectedRep.fullName eventData:[ScriptManager sharedInstance].lastAction.key];
            NSURL* callUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.selectedRep.phone]];
            if ([[UIApplication sharedApplication] canOpenURL:callUrl]) {
                [[UIApplication sharedApplication] openURL:callUrl];
            }
            else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This representative hasn't given us their phone number." preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
            }
        }]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:confirmCallAlertController animated:YES completion:nil];
    }
    else {
        
        NSString *message;
        if (self.selectedRep) {
            message = @"This rep hasn't given us their phone number, try tweeting at them instead.";
        }
        else {
            message = @"Please select a rep first.";
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)presentScriptView {
    
    UIViewController *infoViewController = (UIViewController *)[[[NSBundle mainBundle] loadNibNamed:@"ScriptDialog" owner:self options:nil] objectAtIndex:0];
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

- (void)presentEmailComposer {
    
    if (self.selectedRep.bioguide.length > 0) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:kRepContactFormsJSON ofType:@"json"];
        NSData *contactFormsJSON = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:nil];
        NSDictionary *contactFormsDict = [NSJSONSerialization JSONObjectWithData:contactFormsJSON options:NSJSONReadingAllowFragments error:nil];
        
        NSString *contactFormURLString = [contactFormsDict valueForKey:self.selectedRep.bioguide];
        if (contactFormURLString.length == 0) {
            [self presentEmailAlert];
            return;
        }
        NSURL *contactFormURL = [NSURL URLWithString:contactFormURLString];
        
        NSString *title = self.selectedRep.title;
        NSString *name = self.selectedRep.fullName;
        NSString *fullName = @"";
        if (title.length > 0 && name.length > 0) {
            fullName = [NSString stringWithFormat:@"%@ %@", title, name];
        }
        else if (name.length > 0) {
            fullName = name;
        }
        else if (title.length > 0) {
            fullName = title;
        }
        self.navigationItem.title = @"";
        [self presentWebViewControllerFromTextView:contactFormURL withTitle:fullName];
        
    }
    else if (self.selectedRep.email.length > 0) {
        
        [self selectMailApp];
    }
    else {
        [self presentEmailAlert];
    }
}

- (void)selectMailApp {
    // try Mail app
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        //        [mailViewController setSubject:@"Subject Goes Here."];
        //        [mailViewController setMessageBody:@"Your message goes here." isHTML:NO];
        [mailViewController setToRecipients:@[self.selectedRep.email]];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else { // try Gmail
        NSString *gmailURL = [NSString stringWithFormat:@"googlegmail:///co?to=%@", self.selectedRep.email];
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
            [[ReportingManager sharedInstance]reportEvent:kEMAIL_EVENT eventFocus:self.selectedRep.email eventData:[ScriptManager sharedInstance].lastAction.key];
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

- (void)presentEmailAlert {
    
    NSString *message;
    if (self.selectedRep) {
        message = @"This legislator hasn't given us their email address, try calling instead.";
    }
    else {
        message = @"Please select a rep first";
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)presentTweetComposerInActionDetail {
    
    if (self.selectedRep.twitter.length > 0) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *tweetSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            NSString *initialText = [NSString stringWithFormat:@".@%@", self.selectedRep.twitter];
            [tweetSheetOBJ setInitialText:initialText];
            [tweetSheetOBJ setCompletionHandler:^(SLComposeViewControllerResult result) {
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"Twitter Post Canceled");
                        
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"Twitter Post Sucessful");
                        [[ReportingManager sharedInstance]reportEvent:kTWEET_EVENT eventFocus:self.selectedRep.twitter eventData:[ScriptManager sharedInstance].lastAction.key];
                        
                        break;
                    default:
                        break;
                }
            }];
            [self presentViewController:tweetSheetOBJ animated:YES completion:nil];
        }
    }
    else {
        
        NSString *message;
        if (self.selectedRep) {
            message = @"This rep hasn't given us their twitter handle, try calling them instead.";
        }
        else {
            message = @"Please select a rep first.";
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)presentWebViewControllerFromTextView:(NSURL *)url withTitle:(NSString *)title {
    
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    WebViewController *webViewController = (WebViewController *)[repsSB instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = url;
    webViewController.title = @"TAKE ACTION";
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - NSNotifications

-(void)registerCallStateNotification {
    //Register for notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callStateDidChange:) name:@"CTCallStateDidChange" object:nil];
    
    //Instantiate call center
    CTCallCenter *callCenter = [[CTCallCenter alloc] init];
    self.callCenter = callCenter;
    
    self.callCenter.callEventHandler = ^(CTCall* call) {
        
        //Announce that we've had a state change in CallCenter
        NSDictionary *dict = [NSDictionary dictionaryWithObject:call.callState forKey:@"callState"]; [[NSNotificationCenter defaultCenter] postNotificationName:@"CTCallStateDidChange" object:nil userInfo:dict];
    };
}

- (void)callStateDidChange:(NSNotification *)notification {
    //Log the notification
    NSLog(@"Notification : %@", notification);
    NSString *callInfo = [[notification userInfo] objectForKey:@"callState"];
    if ([callInfo isEqualToString: CTCallStateDialing]) {
        //The call state, before connection is established, when the user initiates the call.
        NSLog(@"****** call is dialing ******");
        [self scheduleNotification];
    }
    if ([callInfo isEqualToString: CTCallStateIncoming]) {
        //The call state, before connection is established, when a call is incoming but not yet answered by the user.
        NSLog(@"***** call is incoming ******");
    }
    if ([callInfo isEqualToString: CTCallStateConnected]) {
        //The call state when the call is fully established for all parties involved.
        NSLog(@"***** call connected *****");
    }
    if ([callInfo isEqualToString: CTCallStateDisconnected]) {
        //the call state has ended
        NSLog(@"***** call ended *****");
    }
}

#pragma mark - UNNotifications

- (void)scheduleNotification {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center removeAllDeliveredNotifications];
    NSLog(@"LOCAL NOTI FIRED-----------");
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:1.5];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear +
                                                                             NSCalendarUnitMonth + NSCalendarUnitDay +
                                                                             NSCalendarUnitHour + NSCalendarUnitMinute +
                                                                             NSCalendarUnitSecond)
                                                                   fromDate:date];
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    content.title = @"Swipe down for full message";
    content.body = [ScriptManager sharedInstance].lastAction.script.length ? [ScriptManager sharedInstance].lastAction.script : kGenericScript;
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"localNoti" content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:nil];
}

@end
