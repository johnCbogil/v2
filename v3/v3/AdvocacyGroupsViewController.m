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
@import Firebase;

@interface AdvocacyGroupsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) NSInteger selectedSegment;
@property (strong, nonatomic) NSMutableArray *listOfFollowedAdvocacyGroups;
@property (strong, nonatomic) NSMutableArray *listofCallsToAction;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addAdvocacyGroupButton;

@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;

@end

@implementation AdvocacyGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTableView];

    self.navigationItem.hidesBackButton = YES;

    self.segmentControl.tintColor = [UIColor voicesOrange];
    
    self.listofCallsToAction = [NewsFeedManager sharedInstance].newsFeedObjects;
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];

    [self userAuth];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    if (self.selectedSegment) {
        [self fetchFollowedGroups];
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
            NSLog(@"%@", snapshot.value[@"userID"]);
        } withCancelBlock:^(NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    }
}

// This needs to be fixed
- (void)fetchFollowedGroups {
    __weak AdvocacyGroupsViewController *weakSelf = self;
    [[[self.usersRef child:self.currentUserID]child:@"groups" ] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if ([snapshot.value isKindOfClass:[NSNull class]]) {
            return;
        }
        NSDictionary *groups = snapshot.value;
        NSMutableArray *groupsArray = [NSMutableArray array];
        [groups enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *name = key;
            if (name.length > 0) {
                [groupsArray addObject:name];
            }
        }];
        
        weakSelf.listOfFollowedAdvocacyGroups = [NSMutableArray arrayWithArray:groupsArray];
        [weakSelf.tableView reloadData];

    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)removeGroup:(NSString *)groupName {
    
    // Remove group from local array
    [self.listOfFollowedAdvocacyGroups removeObject:groupName];
    
    // Remove group from user's groups
    [[[[self.usersRef child:self.currentUserID]child:@"groups"]child:groupName]removeValue];
    
    // Remove user from group's users
    [[[[self.groupsRef child:@"ACLU"]child:@"followers"]child:self.currentUserID]removeValue];
}

- (IBAction)listOfAdvocacyGroupsButtonDidPress:(id)sender {
    
    UIStoryboard *advocacyGroupsStoryboard = [UIStoryboard storyboardWithName:@"AdvocacyGroups" bundle: nil];
    ListOfAdvocacyGroupsViewController *viewControllerB = (ListOfAdvocacyGroupsViewController *)[advocacyGroupsStoryboard instantiateViewControllerWithIdentifier: @"ListOfAdvocacyGroupsViewController"];
    viewControllerB.currentUserID = self.currentUserID;
    [self.navigationController pushViewController:viewControllerB animated:YES];
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectedSegment == 0) {
        return self.listofCallsToAction.count;
    }
    else {
        return self.listOfFollowedAdvocacyGroups.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedSegment == 0) {
        CallToActionTableViewCell  *cell = (CallToActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CallToActionTableViewCell" forIndexPath:indexPath];
        [cell initWithData:[self.listofCallsToAction objectAtIndex:indexPath.row]];
        return cell;
    }
    else {
        UITableViewCell  *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = [self.listOfFollowedAdvocacyGroups[indexPath.row]valueForKey:@"name"];
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectedSegment == 0) {
        //[self followAdovacyGroup:[self.listofCallsToAction objectAtIndex:indexPath.row]];
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
       // [self removeFollower:self.listOfFollowedAdvocacyGroups[indexPath.row]];
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
    [self.tableView reloadData];
}

@end