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

    [self.tableView registerNib:[UINib nibWithNibName: @"CompletedActionTableViewCell" bundle:nil] forCellReuseIdentifier:@"CompletedActionTableViewCell"];
    [self configureTableView];
    
//    // FOR EACH GROUP IN THE LIST OF USERS FOLLOWED GROUPS
    for (Group *group in [CurrentUser sharedInstance].listOfFollowedGroups) {
        //    // FETCH ACTIONS
        [[FirebaseManager sharedInstance]fetchActionsForGroup:group withCompletion:^(NSArray *listOfActions) {
            
            // FOR EACH ACTION IN THE LIST OF ACTIOJNS
            for (Action *action in listOfActions) {
             
                for (NSDictionary *user in action.usersCompleted) {
                    
                    // CREATE A USERCOMPLETED MODEL OBJECT
                    CompletedAction *completedAction = [[CompletedAction alloc]initWithData:user];
                    
                    // CREATE ARRAY OF USERCOMPLETED MODEL OBJECTS AND SEND TO TABLEVIEW
                    [self.tableViewDataSource addObject:completedAction];
                }
            }
        }];
    }
}

- (void)configureTableView {
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.tableViewDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CompletedActionTableViewCell *cell = (CompletedActionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"CompletedActionTableViewCell" forIndexPath:indexPath];
    
    return cell;
}


@end
