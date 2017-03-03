//
//  TakeActionViewController.m
//  Voices
//
//  Created by John Bogil on 12/19/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "TakeActionViewController.h"

#import "Action.h"
#import "ActionDetailViewController.h"
#import "ActionTableViewCell.h"
#import "CurrentUser.h"
#import "Group.h"
#import "GroupDetailViewController.h"
#import "GroupTableViewCell.h"
#import "GroupsEmptyState.h"
#import "ListOfGroupsViewController.h"
#import "FirebaseManager.h"


@interface TakeActionViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) NSInteger selectedSegment;
@property (nonatomic, assign) BOOL isUserAuthInProgress;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) GroupsEmptyState *emptyStateView;
@end

@implementation TakeActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureTableView];
    [self createActivityIndicator];

    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];

    self.segmentControl.tintColor = [UIColor voicesOrange];
    self.isUserAuthInProgress = NO;
}

- (void)configureEmptyState {
    if (self.segmentControl.selectedSegmentIndex) {
        [self.emptyStateView updateLabels:kGroupEmptyStateTopLabel bottom:kGroupEmptyStateBottomLabel];
    }
    else {
        [self.emptyStateView updateLabels:kActionEmptyStateTopLabel bottom:kActionEmptyStateBottomLabel];
    }
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([CurrentUser sharedInstance].firebaseUserID) {
        [self fetchFollowedGroupsForCurrentUser];
    }
    else {
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
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActionTableViewCell" bundle:nil]forCellReuseIdentifier:@"ActionTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
}

- (void)createActivityIndicator {
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
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

        // TODO: THIS IS NOT DRY
        if (self.selectedSegment == 0) {
            if (![CurrentUser sharedInstance].listOfActions.count) {
                self.tableView.backgroundView.hidden = NO;
            }
            else {
                self.tableView.backgroundView.hidden = YES;
            }
        }
        else {
            if (![CurrentUser sharedInstance].listOfFollowedGroups.count) {
                self.tableView.backgroundView.hidden = NO;
            }
            else {
                self.tableView.backgroundView.hidden = YES;
            }
        }
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
        NSLog(@"List of Followed Groups: %@", listOfFollowedGroups);
        [self.tableView reloadData];

        [[FirebaseManager sharedInstance]fetchActionsWithCompletion:^(NSArray *listOfActions) {
            [self.tableView reloadData];
        } onError:^(NSError *error) {

        }];
    } onError:^(NSError *error) {
        [self toggleActivityIndicatorOff];
    }];
}

- (IBAction)listOfGroupsButtonDidPress:(id)sender {

    // Allows centering of the nav bar title by making an empty back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
    ListOfGroupsViewController *viewControllerB = (ListOfGroupsViewController *)[takeActionSB instantiateViewControllerWithIdentifier: @"ListOfGroupsViewController"];
    [self.navigationController pushViewController:viewControllerB animated:YES];
}

- (void)learnMoreButtonDidPress:(UIButton*)sender {

    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    // Allows centering of the nav bar title by making an empty back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
    
    // TODO: THERE IS REDUNDANT CODE HERE AND BELOW
    ActionDetailViewController *actionDetailViewController = (ActionDetailViewController *)[takeActionSB instantiateViewControllerWithIdentifier: @"ActionDetailViewController"];
    actionDetailViewController.action = [CurrentUser sharedInstance].listOfActions[indexPath.row];
    Group *currentGroup = [Group groupForAction: [CurrentUser sharedInstance].listOfActions[indexPath.row]];
    actionDetailViewController.group = currentGroup;
    [self.navigationController pushViewController:actionDetailViewController animated:YES];
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectedSegment) {
        return [CurrentUser sharedInstance].listOfFollowedGroups.count;
    }
    else {
        return [CurrentUser sharedInstance].listOfActions.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedSegment == 0) {
        
        ActionTableViewCell *cell = (ActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionTableViewCell" forIndexPath:indexPath];
        [cell.takeActionButton addTarget:self action:@selector(learnMoreButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
        Action *action = [CurrentUser sharedInstance].listOfActions[indexPath.row];
        Group *currentGroup = [Group groupForAction: action];
        [cell initWithGroup:currentGroup andAction:action];
        return cell;
    }
    else {
        GroupTableViewCell *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupTableViewCell" forIndexPath:indexPath];
        Group *group = [CurrentUser sharedInstance].listOfFollowedGroups[indexPath.row];
        [cell initWithGroup:group];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedSegment == 0) {
        return NO;
    }
    else {
        return YES;
    }
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

    UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
    
    // Allows centering of the nav bar title by making an empty back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];

    if (self.segmentControl.selectedSegmentIndex) {
        GroupDetailViewController *groupDetailViewController = (GroupDetailViewController *)[takeActionSB instantiateViewControllerWithIdentifier:@"GroupDetailViewController"];
        groupDetailViewController.group = [CurrentUser sharedInstance].listOfFollowedGroups[indexPath.row];
        [self.navigationController pushViewController:groupDetailViewController animated:YES];
    }
    else {
        
        // TODO: THERE IS REDUNDANT CODE HERE AND ABOVE
        ActionDetailViewController *actionDetailViewController = (ActionDetailViewController *)[takeActionSB instantiateViewControllerWithIdentifier: @"ActionDetailViewController"];
        actionDetailViewController.action = [CurrentUser sharedInstance].listOfActions[indexPath.row];
        Group *currentGroup = [Group groupForAction: [CurrentUser sharedInstance].listOfActions[indexPath.row]];
        actionDetailViewController.group = currentGroup;
        [self.navigationController pushViewController:actionDetailViewController animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segment Control

- (IBAction)segmentControlDidChange:(id)sender {
    [self configureEmptyState];
    self.segmentControl = (UISegmentedControl *) sender;
    self.selectedSegment = self.segmentControl.selectedSegmentIndex;
    if ([CurrentUser sharedInstance].firebaseUserID) {
        [self fetchFollowedGroupsForCurrentUser];
    } else {
        [self userAuth];
    }

    [self.tableView reloadData];
}

@end
