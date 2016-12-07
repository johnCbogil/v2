//
//  ListOfGroupsViewController.m
//  Voices
//
//  Created by John Bogil on 4/20/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ListOfGroupsViewController.h"
#import "GroupDetailViewController.h"
#import "GroupDetailCollectionViewController.h"
#import "GroupTableViewCell.h"
#import "GroupsViewController.h"
#import "Group.h"
#import "CurrentUser.h"

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
    
    self.title = @"Select A Group To Learn More";
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];

    [self configureTableView];
    [self createActivityIndicator];
    [self retrieveGroups];
    
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
            if (!group.debug) {
                [groupsArray addObject:group];
            }
        }];
        weakSelf.listOfGroups = [NSMutableArray arrayWithArray:groupsArray];
        [weakSelf.tableView reloadData];
        [self toggleActivityIndicatorOff];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

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
    
    // Allows centering of the nav bar title by making an empty back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];

    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    GroupDetailCollectionViewController *groupDetailCollectionViewController = (GroupDetailCollectionViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier:@"GroupDetailCollectionViewController"];
    groupDetailCollectionViewController.group = self.listOfGroups[indexPath.row];
    groupDetailCollectionViewController.currentUserID = self.currentUserID;
    [self.navigationController pushViewController:groupDetailCollectionViewController animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

@end
