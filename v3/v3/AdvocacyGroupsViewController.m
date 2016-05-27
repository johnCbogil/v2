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

@interface AdvocacyGroupsViewController () <UITableViewDataSource, UITableViewDelegate, ViewControllerBDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) NSInteger selectedSegment;
//@property (strong, nonatomic) NSMutableArray *listOfAdvocacyGroups;
@property (strong, nonatomic) NSMutableArray *listOfFollowedAdvocacyGroups;
@property (strong, nonatomic) NSMutableArray *listofCallsToAction;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addAdvocacyGroupButton;

@property (strong, nonatomic) NSString *currentUserID;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;

@end

@implementation AdvocacyGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;

    self.segmentControl.tintColor = [UIColor voicesOrange];
    
    self.listofCallsToAction = [NewsFeedManager sharedInstance].newsFeedObjects;
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    if (self.selectedSegment) {
//        [self retrieveFollowedAdovacyGroups];
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
        
        // FETCH FOLLOWED GROUPS
        [[self.usersRef child:self.currentUserID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            // Get user value
            //User *user = [[User alloc] initWithUsername:snapshot.value[@"name"]];
            NSLog(@"%@", snapshot.value[@"userID"]);
            // ...
        } withCancelBlock:^(NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    }
}

- (void)fetchFollowedGroups {
    
}


// NOT SURE IF I NEED THIS
//- (void)addItemViewController:(ListOfAdvocacyGroupsViewController *)controller didFinishEnteringItem:(PFObject *)item{
//    NSLog(@"This was returned from ViewControllerB %@",item);
//}
- (IBAction)listOfAdvocacyGroupsButtonDidPress:(id)sender {
    
    UIStoryboard *advocacyGroupsStoryboard = [UIStoryboard storyboardWithName:@"AdvocacyGroups" bundle: nil];
    ListOfAdvocacyGroupsViewController *viewControllerB = (ListOfAdvocacyGroupsViewController *)[advocacyGroupsStoryboard instantiateViewControllerWithIdentifier: @"ListOfAdvocacyGroupsViewController"];

    
    
//    ListOfAdvocacyGroupsViewController *viewControllerB = [[ListOfAdvocacyGroupsViewController alloc] initWithNibName:@"ListOfAdvocacyGroupsViewController" bundle:nil];
//    viewControllerB.delegate = self;
    [self.navigationController pushViewController:viewControllerB animated:YES];
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectedSegment == 0) {
        return self.listofCallsToAction.count;
    }
    else {
        return self.listOfFollowedAdvocacyGroups.count;
    }}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedSegment == 0) {
        CallToActionTableViewCell  *cell = (CallToActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CallToActionTableViewCell" forIndexPath:indexPath];
        [cell initWithData:[self.listofCallsToAction objectAtIndex:indexPath.row]];
        return cell;
    }
    else {
        AdvocacyGroupTableViewCell  *cell = (AdvocacyGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AdvocacyGroupTableViewCell" forIndexPath:indexPath];
        [cell initWithData:[self.listOfFollowedAdvocacyGroups objectAtIndex:indexPath.row]];
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
//        [self retrieveFollowedAdovacyGroups];
    }
    
    [self.tableView reloadData];
}


@end