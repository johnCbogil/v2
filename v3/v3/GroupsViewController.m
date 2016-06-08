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
#import "NewsFeedManager.h"
#import "CallToActionTableViewCell.h"
#import "ListOfGroupsViewController.h"
#import <Parse/Parse.h>

@interface GroupsViewController () <UITableViewDataSource, UITableViewDelegate, ViewControllerBDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) NSInteger selectedSegment;
//@property (strong, nonatomic) NSMutableArray *listOfAdvocacyGroups;
@property (strong, nonatomic) NSMutableArray *listOfFollowedAdvocacyGroups;
@property (strong, nonatomic) NSMutableArray *listofCallsToAction;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addAdvocacyGroupButton;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CallToActionTableViewCell" bundle:nil]forCellReuseIdentifier:@"CallToActionTableViewCell"];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.segmentControl.tintColor = [UIColor voicesOrange];
    
    [self userAuth];
    //[self retrieveAdovacyGroups];
    
    self.listofCallsToAction = [NewsFeedManager sharedInstance].newsFeedObjects;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    if (self.selectedSegment) {
        [self retrieveFollowedAdovacyGroups];
    }
}


// NOT SURE IF I NEED THIS
- (void)addItemViewController:(ListOfGroupsViewController *)controller didFinishEnteringItem:(PFObject *)item{
    NSLog(@"This was returned from ViewControllerB %@",item);
}
- (IBAction)listOfAdvocacyGroupsButtonDidPress:(id)sender {
    
    UIStoryboard *advocacyGroupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    ListOfGroupsViewController *viewControllerB = (ListOfGroupsViewController *)[advocacyGroupsStoryboard instantiateViewControllerWithIdentifier: @"ListOfGroupsViewController"];

    
    
//    ListOfAdvocacyGroupsViewController *viewControllerB = [[ListOfAdvocacyGroupsViewController alloc] initWithNibName:@"ListOfAdvocacyGroupsViewController" bundle:nil];
    viewControllerB.delegate = self;
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
        GroupTableViewCell  *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupTableViewCell.h" forIndexPath:indexPath];
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
        [self removeFollower:self.listOfFollowedAdvocacyGroups[indexPath.row]];
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
        [self retrieveFollowedAdovacyGroups];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Parse Methods

- (void)retrieveFollowedAdovacyGroups {
    PFQuery *query = [PFQuery queryWithClassName:@"AdvocacyGroups"];
    [query whereKey:@"followers" equalTo:[PFUser currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Retrieve Selected AdvocacyGroups Success, %@", objects);
            self.listOfFollowedAdvocacyGroups = [[NSMutableArray alloc]initWithArray:objects];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Retrieve Selected AdvocacyGroups Error: %@", error);
        }
    }];
}

- (void)retrieveAdovacyGroups {
    PFQuery *query = [PFQuery queryWithClassName:@"AdvocacyGroups"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Retrieve AdvocacyGroup Success");
            //self.listOfAdvocacyGroups = [[NSMutableArray alloc]initWithArray:objects];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Retrieve AdvocacyGroups Error: %@", error);
        }
    }];
}

- (void)userAuth {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Anonymous login failed.");
            } else {
                NSLog(@"Anonymous user logged in: %@", user);
            }
        }];
    }
}

- (void)followAdovacyGroup:(PFObject*)object {
    [[PFInstallation currentInstallation]addUniqueObject:object.objectId forKey:@"channels"];
    NSLog(@"AdGroup: %@", object);
    [[PFInstallation currentInstallation]saveInBackground];
    [object addUniqueObject:[PFUser currentUser].username forKey:@"followers"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Followed!");
        }
        else {
            NSLog(@"Follow Error: %@", error);
        }
    }];
}

- (void)removeFollower:(PFObject*)object {
    [[PFInstallation currentInstallation]removeObject:object.objectId forKey:@"channels"];
    [[PFInstallation currentInstallation]saveInBackground];
    [self.listOfFollowedAdvocacyGroups removeObject:object];
    [object removeObjectForKey:@"followers"];
    [object save];
}

@end