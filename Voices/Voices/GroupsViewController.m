//
//  GroupsViewController.m
//  Voices
//
//  Created by John Bogil on 12/19/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "GroupsViewController.h"
#import "GroupTableViewCell.h"
#import "UIColor+voicesOrange.h"
#import "ActionTableViewCell.h"
#import "GroupTableViewCell.h"
#import "ListOfGroupsViewController.h"
#import "Group.h"
#import "Action.h"

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
@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listOfFollowedGroups = [NSMutableArray array];
    self.listOfActions = @[].mutableCopy;
    
    [self configureTableView];
    [self createActivityIndicator];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.segmentControl.tintColor = [UIColor voicesOrange];
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    self.actionsRef = [self.rootRef child:@"actions"];
    self.isUserAuthInProgress = NO;
    [self userAuth];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.currentUserID) {
        [self fetchFollowedGroups];
    }
}

- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActionTableViewCell" bundle:nil]forCellReuseIdentifier:@"ActionTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    if (self.selectedSegment) {
        self.tableView.estimatedRowHeight = 100.0;
    }
    else {
        self.tableView.estimatedRowHeight = 255.0;
    }
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
    [self.activityIndicatorView stopAnimating];
    });
}

- (void)userAuth {
    if (self.isUserAuthInProgress) {
        return;
    }
    self.isUserAuthInProgress = YES;
    NSString *userId = [[NSUserDefaults standardUserDefaults]stringForKey:@"userID"];
    if (!userId) {
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
    else {
        [self fetchGroupsWithUserId:userId];
        [[self.usersRef child:userId] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.value == [NSNull null]) {
                return;
            }
            NSLog(@"%@", snapshot.value[@"userID"]);
        } withCancelBlock:^(NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    }
}

- (void)fetchGroupsWithUserId:(NSString *)userId {
    self.currentUserID = userId;
    self.isUserAuthInProgress = NO;
    [self fetchFollowedGroups];
}

- (void)fetchFollowedGroups {
    [self toggleActivityIndicatorOn];
    __weak GroupsViewController *weakSelf = self;
    NSMutableArray *groupsArray = [NSMutableArray array];
    
    // For each group that the user belongs to
    [[[self.usersRef child:self.currentUserID] child:@"groups"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // This is happening once per group
        if ([snapshot.value isKindOfClass:[NSNull class]]) {
            return;
        }
        // Retrieve this group's key
        NSString *groupKey = snapshot.key;
        
        // Go to the groups table
        [weakSelf fetchGroupWithKey:groupKey groupsArray:groupsArray];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)fetchGroupWithKey:(NSString *)groupKey groupsArray:(NSMutableArray *)groupsArray {
    [[self.groupsRef child:groupKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) { // Why is this different than NSNull class check above?
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
        //FIXME: why is this different than above comparison to [NSNull class]?
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
        [self toggleActivityIndicatorOff];
    }];
}

- (void)removeGroup:(Group *)group {
    
    // Remove group from local array
    [self.listOfFollowedGroups removeObject:group];
    
    // Remove group from user's groups
    [[[[self.usersRef child:self.currentUserID]child:@"groups"]child:group.key]removeValue];
    
    // Remove user from group's users
    [[[[self.groupsRef child:group.key]child:@"followers"]child:self.currentUserID]removeValue];
    
    // Remove group from user's subscriptions
    [[FIRMessaging messaging]unsubscribeFromTopic:[NSString stringWithFormat:@"/topics/%@",group.key]];
    NSLog(@"User unsubscribed to %@", group.key);
    
    // Remove associated actions
    NSMutableArray *discardedItems = [NSMutableArray array];
    for (Action *action in self.listOfActions) {
        if ([action.groupKey isEqualToString:group.key]) {
            [discardedItems addObject:action];
        }
    }
    [self.listOfActions removeObjectsInArray:discardedItems];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:group.name message:@"You will no longer recieve updates from this group" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)listOfGroupsButtonDidPress:(id)sender {
    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    ListOfGroupsViewController *viewControllerB = (ListOfGroupsViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier: @"ListOfGroupsViewController"];
    viewControllerB.currentUserID = self.currentUserID;
    [self.navigationController pushViewController:viewControllerB animated:YES];
}

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

#pragma mark - Segment Control

- (IBAction)segmentControlDidChange:(id)sender {
    self.segmentControl = (UISegmentedControl *) sender;
    self.selectedSegment = self.segmentControl.selectedSegmentIndex;
    if (self.currentUserID) {
        [self fetchFollowedGroups];
    } else {
        [self userAuth];
    }
    [self.tableView reloadData];
}

@end