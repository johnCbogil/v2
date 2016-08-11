//
//  GroupsViewController.m
//  Voices
//
//  Created by John Bogil on 12/19/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "GroupsViewController.h"
#import "GroupTableViewCell.h"
#import "UIColor+voicesColor.h"
#import "ActionTableViewCell.h"
#import "GroupTableViewCell.h"
#import "ListOfGroupsViewController.h"
#import "ActionDetailViewController.h"
#import "GroupDetailViewController.h"
#import "Group.h"
#import "Action.h"
#import "GroupsEmptyState.h"
#import "VoicesConstants.h"

@import Firebase;
@import FirebaseMessaging;

@interface GroupsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) NSInteger selectedSegment;
@property (strong, nonatomic) NSMutableArray <Group *> *listOfFollowedGroups;
@property (strong, nonatomic) NSMutableArray <Action *> *listOfActions;
@property (nonatomic, assign) BOOL isUserAuthInProgress;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *actionsRef;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) GroupsEmptyState *emptyStateView;
@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listOfFollowedGroups = @[].mutableCopy;
    self.listOfActions = @[].mutableCopy;
    
    [self configureTableView];
    [self createActivityIndicator];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    
    self.segmentControl.tintColor = [UIColor voicesOrange];
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    self.actionsRef = [self.rootRef child:@"actions"];
    self.isUserAuthInProgress = NO;
    [self userAuth];
    
    // TODO: Change this to a delegate, or perhaps this can be addressed by firebase manager refactor
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeGroupFromDetailViewController:) name:@"removeGroup" object:nil];
}

- (void)removeGroupFromDetailViewController:(NSNotification *)notification {
    [self removeGroup:notification.object];
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
    if (self.currentUserID) {
        [self fetchFollowedGroupsForUserId:self.currentUserID];
    }
    else {
        self.tableView.backgroundView.hidden = NO;
    }
    
    [self.tableView reloadData];
}

- (void)configureTableView {
    
    self.emptyStateView = [[EmptyState alloc]init];
    self.tableView.backgroundView = self.emptyStateView;
    if (!self.isUserAuthInProgress) {
        self.tableView.backgroundView.hidden = YES;
    }

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActionTableViewCell" bundle:nil]forCellReuseIdentifier:@"ActionTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.allowsSelection = NO;
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
        
        if (!self.listOfFollowedGroups.count) {
            self.tableView.backgroundView.hidden = NO;
        }
        else {
            self.tableView.backgroundView.hidden = YES;
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
    NSString *userId = [[NSUserDefaults standardUserDefaults]stringForKey:@"userID"];
    if (!userId) {
        [self createAnonymousUser];
           }
    else {
        [self fetchFollowedGroupsForUserId:userId];
    }
}

- (void)createAnonymousUser {
    
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
        if (error) {
            NSLog(@"UserAuth error: %@", error);
            self.isUserAuthInProgress = NO;
            return;
        }
        self.currentUserID = user.uid;
        NSLog(@"Created a new userID: %@", self.currentUserID);
        [[NSUserDefaults standardUserDefaults]setObject:self.currentUserID forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [self.usersRef updateChildValues:@{self.currentUserID : @{@"userID" : self.currentUserID}} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error) {
                NSLog(@"Error adding user to database: %@", error);
                self.isUserAuthInProgress = NO;
                return;
            }
            NSLog(@"Created user in database");
        }];
    }];
}

- (void)fetchFollowedGroupsForUserId:(NSString *)userId {
    self.currentUserID = userId;
    self.isUserAuthInProgress = NO;

    [self toggleActivityIndicatorOn];
    __weak GroupsViewController *weakSelf = self;
    NSMutableArray *groupsArray = [NSMutableArray array];
    
    // For each group that the user belongs to
    [[[self.usersRef child:self.currentUserID] child:@"groups"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // This is happening once per group
        if ([snapshot.value isKindOfClass:[NSNull class]]) {
            [weakSelf toggleActivityIndicatorOff];
            return;
        }
        // Retrieve this group's key
        NSDictionary *groupsKeys = snapshot.value;
        NSArray *keys = groupsKeys.allKeys;
        for (NSString *key in keys) {
            // Go to the groups table
            [weakSelf fetchGroupWithKey:key groupsArray:groupsArray];
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)fetchGroupWithKey:(NSString *)groupKey groupsArray:(NSMutableArray *)groupsArray {
    [[self.groupsRef child:groupKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) { // Why is this different than NSNull class check above?
            [self toggleActivityIndicatorOff];
            return;
        }
        // Iterate through the listOfFollowedGroups and determine the index of the object that passes the following test:
        NSInteger index = [self.listOfFollowedGroups indexOfObjectPassingTest:^BOOL(Group *group, NSUInteger idx, BOOL *stop) {
            if ([group.key isEqualToString:groupKey]) {
                *stop = YES;
                return YES;
            }
            return NO;
            
        }];
        if (index != NSNotFound) {
            // We already have this group in our table
            [self toggleActivityIndicatorOff];
            return;
        }
        
        Group *group = [[Group alloc] initWithKey:groupKey groupDictionary:snapshot.value];
        
        [groupsArray addObject:group];
        self.listOfFollowedGroups = groupsArray;
        [self.tableView reloadData];
        
        // Retrieve the actions for this group
        if(!snapshot.value[@"actions"]) {
            return;
        }
        NSArray *actionKeys = [snapshot.value[@"actions"] allKeys];
        for (NSString *actionKey in actionKeys) {
            [self fetchActionsForActionKey:actionKey];
        }
    }];
}

- (void)fetchActionsForActionKey:(NSString *)actionKey {
    [[self.actionsRef child:actionKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // TODO: why is this different than above comparison to [NSNull class]?
        if (snapshot.value == [NSNull null]) {
            return ;
        }
        
        // Check to see if the action key is in the listOfActions
        NSInteger index = [self.listOfActions indexOfObjectPassingTest:^BOOL(Action *action, NSUInteger idx, BOOL *stop) {
            if ([action.key isEqualToString:actionKey]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (index != NSNotFound) {
            // We already have this group in our table
            return;
        }
        NSLog(@"%@", snapshot.value);
        Action *newAction = [[Action alloc] initWithKey:actionKey actionDictionary:snapshot.value];
        [self.listOfActions addObject:newAction];
        [self.tableView reloadData];
        [self sortActionsByTime];
        [self toggleActivityIndicatorOff];
    }];
}

- (void)sortActionsByTime {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.listOfActions = [self.listOfActions sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
}

- (void)removeGroup:(Group *)group {
    
    // Remove group from local array
    [self.listOfFollowedGroups removeObject:group];
    NSMutableArray *discardedGroups = [NSMutableArray array];
    for (Group *g in self.listOfFollowedGroups) {
        if ([g.key isEqualToString:group.key]) {
            [discardedGroups addObject:g];
        }
    }
    [self.listOfFollowedGroups removeObjectsInArray:discardedGroups];
    
    // Remove group from user's groups
    [[[[self.usersRef child:self.currentUserID]child:@"groups"]child:group.key]removeValue];
    
    // Remove user from group's users
    [[[[self.groupsRef child:group.key]child:@"followers"]child:self.currentUserID]removeValue];
    
    // Remove group from user's subscriptions
    [[FIRMessaging messaging]unsubscribeFromTopic:[NSString stringWithFormat:@"/topics/%@",group.key]];
    NSLog(@"User unsubscribed to %@", group.key);
    
    // Remove associated actions
    NSMutableArray *discardedActions = [NSMutableArray array];
    for (Action *action in self.listOfActions) {
        if ([action.groupKey isEqualToString:group.key]) {
            [discardedActions addObject:action];
        }
    }
    [self.listOfActions removeObjectsInArray:discardedActions];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:group.name message:@"You will no longer receive actions from this group" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)listOfGroupsButtonDidPress:(id)sender {
    
    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    ListOfGroupsViewController *viewControllerB = (ListOfGroupsViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier: @"ListOfGroupsViewController"];
    viewControllerB.currentUserID = self.currentUserID;
    [self.navigationController pushViewController:viewControllerB animated:YES];
}

- (void)learnMoreButtonDidPress:(UIButton*)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    ActionDetailViewController *actionDetailViewController = (ActionDetailViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier: @"ActionDetailViewController"];
    actionDetailViewController.action = self.listOfActions[indexPath.row];
    [self.navigationController pushViewController:actionDetailViewController animated:YES];}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectedSegment) {
        return self.listOfFollowedGroups.count;
    }
    else {
        return self.listOfActions.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedSegment == 0) {
        ActionTableViewCell *cell = (ActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionTableViewCell" forIndexPath:indexPath];
        [cell.learnMoreButton addTarget:self action:@selector(learnMoreButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
        Action *action = self.listOfActions[indexPath.row];
        [cell initWithAction:action];
        return cell;
    }
    else {
        GroupTableViewCell *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupTableViewCell" forIndexPath:indexPath];
        Group *group = self.listOfFollowedGroups[indexPath.row];
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
        [self removeGroup:self.listOfFollowedGroups[indexPath.row]];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    if (self.segmentControl.selectedSegmentIndex) {
        GroupDetailViewController *groupDetailViewController = (GroupDetailViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier:@"GroupDetailViewController"];
        groupDetailViewController.group = self.listOfFollowedGroups[indexPath.row];
        groupDetailViewController.currentUserID = self.currentUserID;
        [self.navigationController pushViewController:groupDetailViewController animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedSegment) {
        return 75.0;
    }
    else {
        self.tableView.estimatedRowHeight = 255.0;
        return self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
}

#pragma mark - Segment Control

- (IBAction)segmentControlDidChange:(id)sender {
    [self configureEmptyState];
    self.segmentControl = (UISegmentedControl *) sender;
    self.selectedSegment = self.segmentControl.selectedSegmentIndex;
    if (self.currentUserID) {
        [self fetchFollowedGroupsForUserId:self.currentUserID];
    } else {
        [self userAuth];
    }
    if (!self.selectedSegment) {
        self.tableView.allowsSelection = NO;
    }
    else {
        self.tableView.allowsSelection = YES;
    }
    [self.tableView reloadData];
}

@end