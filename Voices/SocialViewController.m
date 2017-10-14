//
//  SocialViewController.m
//  Voices
//
//  Created by John Bogil on 10/9/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "SocialViewController.h"
#import "FirebaseManager.h"
#import "CurrentUser.h"
#import "Group.h"
#import "Action.h"
#import "CompletedAction.h"
#import "CompletedActionTableViewCell.h"

@interface SocialViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tableViewDataSource;

@end

@implementation SocialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Community";
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    [self configureTableView];
    
    
    // FOR EACH ACTION IN THE LIST OF ACTIOJNS
    [[FirebaseManager sharedInstance] fetchFollowedGroupsForCurrentUserWithCompletion:^(NSArray *listOfFollowedGroups) {
        for (Group *group in [CurrentUser sharedInstance].listOfFollowedGroups) {
            [[FirebaseManager sharedInstance] fetchActionsForGroup:group withCompletion:^(NSArray *listOfActions) {
                [self updateTableWithActions:listOfActions];
            }];
        }
    } onError:^(NSError *error) {
        
    }];
    
//    for (Action *action in [CurrentUser sharedInstance].listOfActions) {
//
//        for (NSDictionary *user in action.usersCompleted) {
//
//            // CREATE A USERCOMPLETED MODEL OBJECT
//            CompletedAction *completedAction = [[CompletedAction alloc]initWithData:action.usersCompleted[user]];
//
//            // CREATE ARRAY OF USERCOMPLETED MODEL OBJECTS AND SEND TO TABLEVIEW
//            [self.tableViewDataSource addObject:completedAction];
//            [self.tableView reloadData];
//        }
//    }
}

- (void)updateTableWithActions:(NSArray<Action *> *)actions {
    for (Action *action in actions) {
        for (NSDictionary *user in action.usersCompleted) {
            // CREATE A USERCOMPLETED MODEL OBJECT
            CompletedAction *completedAction = [[CompletedAction alloc] initWithData:action.usersCompleted[user]];
            
            // CREATE ARRAY OF USERCOMPLETED MODEL OBJECTS AND SEND TO TABLEVIEW
            [self.tableViewDataSource addObject:completedAction];
        }
    }
    [self.tableView reloadData];
}

- (void)configureTableView {
    
    self.tableViewDataSource = @[].mutableCopy;
    [self.tableView registerNib:[UINib nibWithNibName: @"CompletedActionTableViewCell" bundle:nil] forCellReuseIdentifier:@"CompletedActionTableViewCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.tableViewDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CompletedActionTableViewCell *cell = (CompletedActionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"CompletedActionTableViewCell" forIndexPath:indexPath];
    [cell initWithData:self.tableViewDataSource[indexPath.row]];
    
    return cell;
}


@end
