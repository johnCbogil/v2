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
#import "FirebaseManager.h"
#import "GroupsEmptyState.h"
#import "ListOfGroupsViewController.h"
#import "ScriptManager.h"
#import "UIViewController+Alert.h"
#import "VoicesUtilities.h"

@interface TakeActionViewController () <UITableViewDataSource, UITableViewDelegate, PresentThankYouAlertDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) GroupsEmptyState *emptyStateView;
@property (weak, nonatomic) IBOutlet UILabel *takeActionLabel;
@property (weak, nonatomic) IBOutlet UIButton *addGroupButton;
@property (nonatomic) NSUInteger actionsCompletedCount;
@property (strong, nonatomic) NSMutableArray *tableViewDataSource;
@property (weak, nonatomic) IBOutlet UILabel *gettingActionsLabel;

@end

@implementation TakeActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureActivityIndicator];
    [self configureNavigationBar];
    [self configureObservers];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)configureObservers {
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchCompletedActionCount) name:@"refreshHeaderCell" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(toggleActivityIndicatorOn) name:@"startFetchingActions" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(toggleActivityIndicatorOff) name:@"stopFetchingActions" object:nil];
}

- (void)configureNavigationBar {
    
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    self.addGroupButton.tintColor = [UIColor voicesOrange];
    self.takeActionLabel.font = [UIFont voicesBoldFontWithSize:40];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if ([CurrentUser sharedInstance].firebaseUserID) {
        
        [self fetchFollowedGroupsForCurrentUser];
    }
    
    if ([CurrentUser sharedInstance].listOfFollowedGroups.count) {
        self.tableView.backgroundView.hidden = YES;
    }
    else {
        self.tableView.backgroundView.hidden = NO;
    }

    [self fetchActions];
}

- (void)configureTableView {
    
    [self fetchCompletedActionCount];
    self.emptyStateView = [[GroupsEmptyState alloc]init];
    self.tableView.backgroundView = self.emptyStateView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName: kActionCellReuse bundle:nil]forCellReuseIdentifier: kActionCellReuse];
    [self.tableView registerNib:[UINib nibWithNibName: kActionFeedHeaderTableViewCell bundle:nil]forCellReuseIdentifier: kActionFeedHeaderTableViewCell];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
}

- (void)configureActivityIndicator {
    
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
        [self.activityIndicatorView stopAnimating];
    });
}

#pragma mark - Firebase Methods

- (void)fetchCompletedActionCount {
    
    [[FirebaseManager sharedInstance] fetchListOfCompletedActionsWithCompletion:^(NSArray *listOfCompletedActions) {
        self.actionsCompletedCount = listOfCompletedActions.count;
        [self refreshHeaderCell];
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}

- (void)fetchFollowedGroupsForCurrentUser {
    
    [[FirebaseManager sharedInstance]fetchFollowedGroupsForCurrentUserWithCompletion:^(NSArray *listOfFollowedGroups) {
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
    actionDetailViewController.action = self.tableViewDataSource[indexPath.row-1];
    Group *currentGroup = [Group groupForAction: self.tableViewDataSource[indexPath.row-1]];
    actionDetailViewController.group = currentGroup;
    [ScriptManager sharedInstance].lastAction = self.tableViewDataSource[indexPath.row-1];
    [self.navigationController pushViewController:actionDetailViewController animated:YES];
}

- (void)fetchActions {
    
    self.tableViewDataSource = @[].mutableCopy;
    for (Group *group in [CurrentUser sharedInstance].listOfFollowedGroups) {
        
        [[FirebaseManager sharedInstance]fetchActionsForGroup:group withCompletion:^(NSArray *listOfActions) {
            
            for (Action *action in listOfActions) {
            
                if ([self shouldAddActionToList:action]) {
                    [self.tableViewDataSource addObject:action];
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
                    self.tableViewDataSource = [self.tableViewDataSource sortedArrayUsingDescriptors:@[sort]].mutableCopy;
                    [self.tableView reloadData];
                }
            }
        }];
    }
    [self.tableView reloadData];
}

- (BOOL)shouldAddActionToList:(Action *)action {

    NSDate *currentTime = [NSDate date];

    if (action.timestamp < currentTime.timeIntervalSince1970) {

        NSInteger index = [self.tableViewDataSource indexOfObjectPassingTest:^BOOL(Action *actionInArray, NSUInteger idx, BOOL *stop) {
            if ([action.key isEqualToString:actionInArray.key]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (index != NSNotFound) {
            // We already have this action in our table
            return NO;
        }

        BOOL debug = [VoicesUtilities isInDebugMode];
        // if app is in debug, add all groups
        if (debug) {
            return YES;
        }
        // if app is not in debug, add only non-debug groups
        else if (!action.debug) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.tableViewDataSource.count) {
        return self.tableViewDataSource.count + 1;
    }
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        ActionFeedHeaderTableViewCell *cell = (ActionFeedHeaderTableViewCell *)[tableView dequeueReusableCellWithIdentifier: kActionFeedHeaderTableViewCell forIndexPath:indexPath];
        [cell refreshTotalActionsCompleted:self.actionsCompletedCount];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        ActionTableViewCell *cell = (ActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier: kActionCellReuse forIndexPath:indexPath];
        Action *action = self.tableViewDataSource[indexPath.row - 1];
        Group *currentGroup = [Group groupForAction:action];
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
    [cell refreshTotalActionsCompleted:self.actionsCompletedCount];
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
