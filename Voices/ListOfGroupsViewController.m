//
//  ListOfGroupsViewController.m
//  Voices
//
//  Created by John Bogil on 4/20/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ListOfGroupsViewController.h"
#import "GroupDetailViewController.h"
#import "GroupTableViewCell.h"
#import "GroupsViewController.h"
#import "Group.h"
#import "UIFont+voicesFont.h"
#import "UIColor+voicesOrange.h"

@import Firebase;
@import FirebaseMessaging;

@interface ListOfGroupsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *listOfGroups;
@property (strong, nonatomic) NSArray *listOfFollowedGroups;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ListOfGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select A Group To Follow";
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];

    [self configureTableView];
    [self createActivityIndicator];
    [self retrieveGroups];
    
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
}

- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupTableViewCell"];
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

#pragma mark - Firebase methods

- (void)retrieveGroups {
    [self toggleActivityIndicatorOn];
    __weak ListOfGroupsViewController *weakSelf = self;
    [self.groupsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *groups = snapshot.value;
        NSMutableArray *groupsArray = [NSMutableArray array];
        [groups enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            Group *group = [[Group alloc] initWithKey:key groupDictionary:obj];
            [groupsArray addObject:group];
        }];
        weakSelf.listOfGroups = [NSMutableArray arrayWithArray:groupsArray];
        [weakSelf.tableView reloadData];
        [self toggleActivityIndicatorOff];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

//- (void)followGroup:(Group *)group {
//    
//    // Check if the current user already belongs to selected group or not
//    FIRDatabaseReference *currentUserRef = [[[self.usersRef child:self.currentUserID]child:@"groups"]child:group.key];
//    [currentUserRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        NSString *result = snapshot.value == [NSNull null] ? @"is not" : @"is";
//        NSLog(@"User %@ a member of selected group", result);
//        if (snapshot.value == [NSNull null]) {
//            
//            // Add group to user's groups
//            [[[self.usersRef child:_currentUserID]child:@"groups"] updateChildValues:@{group.key :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
//                if (error) {
//                    NSLog(@"write error: %@", error);
//                }
//            }];
//            
//            // Add user to group's users
//            [[[self.groupsRef child:group.key]child:@"followers"] updateChildValues:@{self.currentUserID :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
//                if (error) {
//                    NSLog(@"write error: %@", error);
//                }
//                else {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:group.name message:@"You will now recieve updates from this group" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
//                    [alert show];
//                }
//            }];
//            
//            // Add group to user's subscriptions
//            [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", group.key]];
//            NSLog(@"User subscribed to %@", group.key);
//        }
//        else {
//            // feedback goes here
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:group.name message:@"You already belong to this group" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
//            [alert show];
//        }
//    } withCancelBlock:^(NSError * _Nonnull error) {
//        NSLog(@"%@", error);
//    }];
//}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listOfGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupTableViewCell  *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupTableViewCell" forIndexPath:indexPath];
    [cell initWithGroup:self.listOfGroups[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    GroupDetailViewController *groupDetailViewController = (GroupDetailViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier:@"GroupDetailViewController"];
    groupDetailViewController.group = self.listOfGroups[indexPath.row];
    groupDetailViewController.currentUserID = self.currentUserID;
    [self.navigationController pushViewController:groupDetailViewController animated:YES];

    
//    [self followGroup:self.listOfGroups[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

@end
