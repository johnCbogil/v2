//
//  AdvocacyGroupsViewController.m
//  Voices
//
//  Created by John Bogil on 12/19/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "AdvocacyGroupsViewController.h"
#import "AdvocacyGroupTableViewCell.h"
#import "UIColor+voicesOrange.h"
#import "NewsFeedManager.h"
#import "CallToActionTableViewCell.h"
#import "ListOfAdvocacyGroupsViewController.h"
#import "Group.h"

@import Firebase;
@import FirebaseMessaging;

@interface AdvocacyGroupsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) NSInteger selectedSegment;
@property (strong, nonatomic) NSMutableArray <Group *> *listOfFollowedAdvocacyGroups;
@property (strong, nonatomic) NSMutableArray *listOfActions;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addAdvocacyGroupButton;

@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *actionsRef;

@end

@implementation AdvocacyGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listOfFollowedAdvocacyGroups = [NSMutableArray array];
    self.listOfActions = @[].mutableCopy;
    
    [self createTableView];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.segmentControl.tintColor = [UIColor voicesOrange];
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    self.actionsRef = [self.rootRef child:@"actions"];
    
    [self userAuth];
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    if (self.selectedSegment) {
        [self fetchFollowedGroups];
    }
    else {
        [self fetchActions];
    }
}

- (void)createTableView {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"AdvocacyGroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"AdvocacyGroupTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CallToActionTableViewCell" bundle:nil]forCellReuseIdentifier:@"CallToActionTableViewCell"];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)userAuth {
    if (![[NSUserDefaults standardUserDefaults]stringForKey:@"userID"]) {
        [[FIRAuth auth]
         signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
             if (!error) {
                 self.currentUserID = user.uid;
                 NSLog(@"Created a new userID: %@", self.currentUserID);
                 [[NSUserDefaults standardUserDefaults]setObject:self.currentUserID forKey:@"userID"];
                 [[NSUserDefaults standardUserDefaults]synchronize];
                 
                 [self.usersRef updateChildValues:@{self.currentUserID : @{@"userID" : self.currentUserID}} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                     if (!error) {
                         NSLog(@"Created user in database");
                     }
                     else {
                         NSLog(@"Error adding user to database: %@", error);
                     }
                 }];
             }
             else {
                 NSLog(@"UserAuth error: %@", error);
             }
         }];
    }
    else {
        
        self.currentUserID = [[NSUserDefaults standardUserDefaults]stringForKey:@"userID"];
        
        [[self.usersRef child:self.currentUserID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.value == [NSNull null]) {
                return;
            }
            NSLog(@"%@", snapshot.value[@"userID"]);
        } withCancelBlock:^(NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    }
}

- (void)fetchFollowedGroups {
    __weak AdvocacyGroupsViewController *weakSelf = self;
    NSMutableArray *groupsArray = [NSMutableArray array];
    
    // For each group that the user belongs to
    [[[self.usersRef child:self.currentUserID] child:@"groups"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // This is happening once per group
        if (![snapshot.value isKindOfClass:[NSNull class]]) {
            
            // Retrieve this group's key
            NSString *groupKey = snapshot.key;
            
            // Go to the groups table
            [[self.groupsRef child:groupKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if (snapshot.value != [NSNull null]) {
                    
                    // Iterate through the listOfFollowedAdvocacyGroups and determine the index of the object that passes the following test:
                    NSUInteger index = [weakSelf.listOfFollowedAdvocacyGroups indexOfObjectPassingTest:^BOOL(Group *group, NSUInteger idx, BOOL *stop) {
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
                    weakSelf.listOfFollowedAdvocacyGroups = groupsArray;
                    // TODO: Possibe cleaner solution then refreshing the table multiple times:
                    // Count how many groups the user belongs too, then only refresh the table when
                    // listOfFollowedAdvocacyGroups has that count.
                    [weakSelf.tableView reloadData];
                }
            }];
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)fetchActions {
    
    __weak AdvocacyGroupsViewController *weakSelf = self;
    
    // For each group that the user belongs to
    for (Group *group in self.listOfFollowedAdvocacyGroups) {
        
        // Retrieve group data
        [[[self.groupsRef child:group.key] child:@"actions"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (![snapshot.value isKindOfClass:[NSNull class]]) {
                
                // Retrieve this action's key
                NSString *actionKey = snapshot.key;
                
                // Retrieve the actions for this group
                [[weakSelf.actionsRef child:actionKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    if (snapshot.value != [NSNull null]) {
                        
                        // Iterate through the listOfFollowedAdvocacyGroups and determine the index of the object that passes the following test:
                        NSUInteger index = [weakSelf.listOfFollowedAdvocacyGroups indexOfObjectPassingTest:^BOOL(Group *group, NSUInteger idx, BOOL *stop) {
                            if ([group.key isEqualToString:actionKey]) {
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
                    }
                }];
            }
        } withCancelBlock:^(NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    }
}

- (void)removeGroup:(Group *)group {
    
    // Remove group from local array
    [self.listOfFollowedAdvocacyGroups removeObject:group];
    
    // Remove group from user's groups
    [[[[self.usersRef child:self.currentUserID]child:@"groups"]child:group.key]removeValue];
    
    // Remove user from group's users
    [[[[self.groupsRef child:group.key]child:@"followers"]child:self.currentUserID]removeValue];
    
    // Remove group from user's subscriptions
    [[FIRMessaging messaging]unsubscribeFromTopic:[NSString stringWithFormat:@"/topics/%@",group.key]];
    
    NSLog(@"User unsubscribed to %@", group.key);
}

- (IBAction)listOfAdvocacyGroupsButtonDidPress:(id)sender {
    UIStoryboard *advocacyGroupsStoryboard = [UIStoryboard storyboardWithName:@"AdvocacyGroups" bundle: nil];
    ListOfAdvocacyGroupsViewController *viewControllerB = (ListOfAdvocacyGroupsViewController *)[advocacyGroupsStoryboard instantiateViewControllerWithIdentifier: @"ListOfAdvocacyGroupsViewController"];
    viewControllerB.currentUserID = self.currentUserID;
    [self.navigationController pushViewController:viewControllerB animated:YES];
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectedSegment) {
        
        return self.listOfFollowedAdvocacyGroups.count;
    }
    else {
        return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedSegment) {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        Group *group = self.listOfFollowedAdvocacyGroups[indexPath.row];
        cell.textLabel.text = group.name;
        return cell;
    }
    else {
        return nil;
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
        [self removeGroup:self.listOfFollowedAdvocacyGroups[indexPath.row]];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedSegment == 0) {
        return 150;
    }
    else {
        return 100;
    }
}

#pragma mark - Segment Control

- (IBAction)segmentControlDidChange:(id)sender {
    self.segmentControl = (UISegmentedControl *) sender;
    self.selectedSegment = self.segmentControl.selectedSegmentIndex;
    
    if (self.selectedSegment) {
        [self fetchFollowedGroups];
    }
    else {
        [self fetchActions];
    }
    [self.tableView reloadData];
}

@end