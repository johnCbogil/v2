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

@interface SocialViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SocialViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureTableView];
    
//    // FOR EACH GROUP IN THE LIST OF USERS FOLLOWED GROUPS
    for (Group *group in [CurrentUser sharedInstance].listOfFollowedGroups) {
        //    // FETCH ACTIONS
        [[FirebaseManager sharedInstance]fetchActionsForGroup:group withCompletion:^(NSArray *listOfActions) {
            
            // FOR EACH ACTION IN THE LIST OF ACTIOJNS
            for (Action *action in listOfActions) {
             
                for (NSString *user in action.usersCompleted) {
                    
                    // CREATE A USERCOMPLETED MODEL OBJECT
                    
                    // CREATE ARRAY OF USERCOMPLETED MODEL OBJECTS AND SEND TO TABLEVIEW

                }
            }
        }];
    }
//    

    
    
    
}

- (void)configureTableView {
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id cell;
    return cell;
}


@end
