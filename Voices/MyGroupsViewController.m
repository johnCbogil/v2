//
//  MyGroupsViewController.m
//  Voices
//
//  Created by Bogil, John on 8/12/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "MyGroupsViewController.h"
#import "CurrentUser.h"
#import "FirebaseManager.h"
#import "GroupTableViewCell.h"
#import "GroupDetailViewController.h"

@interface MyGroupsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MyGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Groups";
    
    [self configureTableView];
    self.navigationController.navigationBarHidden = NO;
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([CurrentUser sharedInstance].firebaseUserID) {
        
        [self fetchFollowedGroupsForCurrentUser];
    }
}

- (void)configureTableView {
 
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupTableViewCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)fetchFollowedGroupsForCurrentUser {
//    self.isUserAuthInProgress = NO;
//    [self toggleActivityIndicatorOn];
    
    [[FirebaseManager sharedInstance]fetchFollowedGroupsForCurrentUserWithCompletion:^(NSArray *listOfFollowedGroups) {
//        [self toggleActivityIndicatorOff];
        [self.tableView reloadData];
        
    } onError:^(NSError *error) {
//        [self toggleActivityIndicatorOff];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [CurrentUser sharedInstance].listOfFollowedGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GroupTableViewCell *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupTableViewCell" forIndexPath:indexPath];
    Group *group = [CurrentUser sharedInstance].listOfFollowedGroups[indexPath.row];
    [cell initWithGroup:group];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
    GroupDetailViewController *groupDetailViewController = (GroupDetailViewController *)[takeActionSB instantiateViewControllerWithIdentifier:@"GroupDetailViewController"];
    groupDetailViewController.group = [CurrentUser sharedInstance].listOfFollowedGroups[indexPath.row];
    [self.navigationController pushViewController:groupDetailViewController animated:YES];
}

@end
