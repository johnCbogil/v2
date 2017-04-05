//
//  NewActionDetailViewController.m
//  Voices
//
//  Created by John Bogil on 3/20/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailViewController.h"
#import "NewActionDetailTopTableViewCell.h"
#import "NewActionDetailMiddleTableViewCell.h"
#import "NewActionDetailBottomTableViewCell.h"
#import "SearchViewController.h"
#import "LocationService.h"
#import "RepsManager.h"
#import "ReportingManager.h"
#import "ScriptManager.h"
#import "WebViewController.h"
#import <Social/Social.h>

// TODO: HOOK UP ACTION BUTTONS

@interface NewActionDetailViewController () <UITableViewDelegate, UITableViewDataSource, SelectRepDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) Representative *selectedRep;

@end

@implementation NewActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.group.name;
    [self configureTableview];
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (homeAddress) {
        [self fetchRepsForHomeAddress:homeAddress];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSearchViewController) name:@"presentSearchViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCaller) name:@"presentCaller" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEmailComposer) name:@"presentEmailComposer" object:nil];
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
    [self.tableview registerNib:[UINib nibWithNibName:@"NewActionDetailTopTableViewCell" bundle:nil]forCellReuseIdentifier:@"NewActionDetailTopTableViewCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"NewActionDetailMiddleTableViewCell" bundle:nil]forCellReuseIdentifier:@"NewActionDetailMiddleTableViewCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"NewActionDetailBottomTableViewCell" bundle:nil]forCellReuseIdentifier:@"NewActionDetailBottomTableViewCell"];
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
}

#pragma mark - UITableView Delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        NewActionDetailTopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewActionDetailTopTableViewCell"];
        [cell initWithAction:self.action andGroup:self.group];
        return cell;
    }
    else if (indexPath.row == 1) {
        NewActionDetailMiddleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewActionDetailMiddleTableViewCell"];
        return cell;
    }
    else {
        NewActionDetailBottomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewActionDetailBottomTableViewCell"];
        cell.delegate = self;
        cell.descriptionTextView.delegate = self;
        [cell initWithAction:self.action];
        return cell;
    }
}

- (void)sendRepToViewController:(Representative *)rep {
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
    
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)presentCaller {
    
    if (self.selectedRep.phone.length) {
        NSString *confirmCallMessage;
        if (self.selectedRep.nickname != nil && ![self.selectedRep.nickname isEqual:[NSNull null]]) {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@. A script will appear when you begin calling.", self.selectedRep.nickname];
        }
        else {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@ %@. A script will appear when you begin calling.", self.selectedRep.firstName, self.selectedRep.lastName];
        }
        
        UIAlertController *confirmCallAlertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@ %@", self.selectedRep.title,self.selectedRep.firstName, self.selectedRep.lastName]  message:confirmCallMessage preferredStyle:UIAlertControllerStyleAlert];
        [confirmCallAlertController addAction:[UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self dismissViewControllerAnimated:YES completion:nil];
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
            message = @"Please select a rep first. ";
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }
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
        
        [self presentWebViewControllerFromTextView:contactFormURL withTitle:fullName];
        
    }
    else if (self.selectedRep.email.length > 0) {
        
        // TODO: WHY IS THIS POSTING A NOTI? NO NEED.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.selectedRep.email];
    }
    else {
        [self presentEmailAlert];
    }
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

- (void)presentWebViewControllerFromTextView:(NSURL *)url withTitle:(NSString *)title {
    
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    WebViewController *webViewController = (WebViewController *)[repsSB instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = url;
    webViewController.title = @"TAKE ACTION";
    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
