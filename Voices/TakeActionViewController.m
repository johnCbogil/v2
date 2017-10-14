//
//  TakeActionViewController.m
//  Voices
//
//  Created by John Bogil on 12/19/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "TakeActionViewController.h"
#import "ActionTableViewCell.h"
#import "ActionFeedHeaderTableViewCell.h"
#import "ActionDetailViewController.h"
#import "CurrentUser.h"

#import "GroupsEmptyState.h"
#import "ListOfGroupsViewController.h"
#import "FirebaseManager.h"
#import "ScriptManager.h"

@interface TakeActionViewController () <UITableViewDataSource, UITableViewDelegate, PresentThankYouAlertDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL isUserAuthInProgress;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) GroupsEmptyState *emptyStateView;
@property (weak, nonatomic) IBOutlet UILabel *takeActionLabel;
@property (weak, nonatomic) IBOutlet UIButton *addGroupButton;
@end

@implementation TakeActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self createActivityIndicator];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    
    self.isUserAuthInProgress = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshHeaderCell) name:@"refreshHeaderCell" object:nil];
    
    [self.navigationController setNavigationBarHidden:YES];
    self.addGroupButton.tintColor = [UIColor voicesOrange];
    self.takeActionLabel.font = [UIFont voicesBoldFontWithSize:40];
}

- (void)configureEmptyState {
    
    [self.emptyStateView updateLabels:kActionEmptyStateTopLabel bottom:kActionEmptyStateBottomLabel];
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if ([CurrentUser sharedInstance].firebaseUserID) {
        
        [self fetchFollowedGroupsForCurrentUser];
    }
    else {
        self.tableView.backgroundView.hidden = NO;
    }
    
    if (![CurrentUser sharedInstance].listOfActions.count) {
        self.tableView.backgroundView.hidden = NO;
    }
    [self.tableView reloadData];
}

- (void)configureTableView {
    
    self.emptyStateView = [[GroupsEmptyState alloc]init];
    self.tableView.backgroundView = self.emptyStateView;
    if (!self.isUserAuthInProgress) {
        self.tableView.backgroundView.hidden = YES;
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName: kActionCellReuse bundle:nil]forCellReuseIdentifier: kActionCellReuse];
    [self.tableView registerNib:[UINib nibWithNibName: kActionFeedHeaderTableViewCell bundle:nil]forCellReuseIdentifier: kActionFeedHeaderTableViewCell];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
}

- (void)createActivityIndicator {
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.color = [UIColor grayColor];
    self.activityIndicatorView.center=self.view.center;
    [self.view addSubview:self.activityIndicatorView];
}

- (void)toggleActivityIndicatorOn {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView startAnimating];
    });
}

- (void)toggleActivityIndicatorOff {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (![CurrentUser sharedInstance].listOfActions.count) {
            self.tableView.backgroundView.hidden = NO;
        }
        else {
            self.tableView.backgroundView.hidden = YES;
        }

        if (![CurrentUser sharedInstance].listOfFollowedGroups.count) {
            self.tableView.backgroundView.hidden = NO;
        }
        else {
            self.tableView.backgroundView.hidden = YES;
        }
        
        // CONFIGURE EMPTY STATE
        
        // IF THERE ARE NO GROUPS
            // DISPLAY DEFAULT EMPTY STATE
        // IF THERE ARE GROUPS BUT NO ACTIONS
            // PRESENT DIFFERENT EMPTY STATE
    });
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Firebase Methods

- (void)userAuth {
    
    if (self.isUserAuthInProgress) {
        return;
    }
    self.isUserAuthInProgress = YES;
    NSString *userID = [[NSUserDefaults standardUserDefaults]stringForKey:@"userID"];
    if (userID) {
        [self fetchFollowedGroupsForCurrentUser];
    }
}

- (void)fetchFollowedGroupsForCurrentUser {
    
    self.isUserAuthInProgress = NO;
    [self toggleActivityIndicatorOn];
    
    [[FirebaseManager sharedInstance]fetchFollowedGroupsForCurrentUserWithCompletion:^(NSArray *listOfFollowedGroups) {
        [self toggleActivityIndicatorOff];
        [self.tableView reloadData];
        
    } onError:^(NSError *error) {
        [self toggleActivityIndicatorOff];
    }];
}

- (void)pushToActionDetail:(NSIndexPath *)indexPath {
    
    // Allows centering of the nav bar title by making an empty back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
    ActionDetailViewController *actionDetailViewController = (ActionDetailViewController *)[takeActionSB instantiateViewControllerWithIdentifier: @"ActionDetailViewController"];
    actionDetailViewController.action = [CurrentUser sharedInstance].listOfActions[indexPath.row-1];
    Group *currentGroup = [Group groupForAction: [CurrentUser sharedInstance].listOfActions[indexPath.row-1]];
    actionDetailViewController.group = currentGroup;
    [ScriptManager sharedInstance].lastAction = [CurrentUser sharedInstance].listOfActions[indexPath.row-1];
    [self.navigationController pushViewController:actionDetailViewController animated:YES];
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([CurrentUser sharedInstance].listOfActions.count) {
        return [CurrentUser sharedInstance].listOfActions.count + 1;
    }
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        ActionFeedHeaderTableViewCell *cell = (ActionFeedHeaderTableViewCell *)[tableView dequeueReusableCellWithIdentifier: kActionFeedHeaderTableViewCell forIndexPath:indexPath];
        [cell refreshTotalActionsCompleted];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        
        // TODO: THIS VC IS GETTING ONLY LWV WI ACTIONS
        ActionTableViewCell *cell = (ActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier: kActionCellReuse forIndexPath:indexPath];
        Action *action = [CurrentUser sharedInstance].listOfActions[indexPath.row-1];
        Group *currentGroup = [Group groupForAction: action];
        [cell initWithGroup:currentGroup andAction:action];
        cell.delegate = self;
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Group *currentGroup = [CurrentUser sharedInstance].listOfFollowedGroups[indexPath.row];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:currentGroup.name
                                                                                 message:@"Are you sure you would like to stop supporting this group?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[FirebaseManager sharedInstance] removeGroup:currentGroup];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [tableView setEditing:NO animated:YES];
        }];
        [alertController addAction:yesAction];
        [alertController addAction:cancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return;
    }
    
    
    // Allows centering of the nav bar title by making an empty back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    
    [self pushToActionDetail:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refreshHeaderCell {
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    ActionFeedHeaderTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell refreshTotalActionsCompleted];
}

#pragma mark - UIAlerts

- (void)presentThankYouAlertForGroup:(Group *)group andAction:(Action *)action {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Action Completed!"
                                                                             message:@"Thank you! Now share this action with others, change happens when many people act together."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"Share..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull alert) {
        
        NSString *shareString = [NSString stringWithFormat:@"Hey, please help me support %@. %@.\n\n https://tryvoices.com/%@", group.name, action.title, group.key];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareString]applicationActivities:nil];
        [self.navigationController presentViewController:activityViewController
                                                animated:YES
                                              completion:^{ }];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cancel];
    [alertController addAction:shareAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)addGroupButtonDidPress:(id)sender {
    
    // Allows centering of the nav bar title by making an empty back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
    ListOfGroupsViewController *viewControllerB = (ListOfGroupsViewController *)[takeActionSB instantiateViewControllerWithIdentifier: @"ListOfGroupsViewController"];
    [self.navigationController pushViewController:viewControllerB animated:YES];
}

@end
