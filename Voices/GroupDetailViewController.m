//
//  GroupDetailViewController.m
//  Voices
//
//  Created by John Bogil on 7/5/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "GroupDetailViewController.h"

@import Firebase;

@interface GroupDetailViewController ()  <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *followGroupButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *policyPositionsLabel;

@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;


@end

@implementation GroupDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    
    [self configureTableView];

}

- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupTableViewCell"];
}

- (IBAction)followGroupButtonDidPress:(id)sender {
    
    [self followGroup:self.group];
}

- (void)followGroup:(Group *)group {
    
    // Check if the current user already belongs to selected group or not
    FIRDatabaseReference *currentUserRef = [[[self.usersRef child:self.currentUserID]child:@"groups"]child:group.key];
    [currentUserRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *result = snapshot.value == [NSNull null] ? @"is not" : @"is";
        NSLog(@"User %@ a member of selected group", result);
        if (snapshot.value == [NSNull null]) {
            
            // Add group to user's groups
            [[[self.usersRef child:_currentUserID]child:@"groups"] updateChildValues:@{group.key :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if (error) {
                    NSLog(@"write error: %@", error);
                }
            }];
            
            // Add user to group's users
            [[[self.groupsRef child:group.key]child:@"followers"] updateChildValues:@{self.currentUserID :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if (error) {
                    NSLog(@"write error: %@", error);
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:group.name message:@"You will now recieve updates from this group" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
                    [alert show];
                }
            }];
            
            // Add group to user's subscriptions
            [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", group.key]];
            NSLog(@"User subscribed to %@", group.key);
        }
        else {
            // feedback goes here
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:group.name message:@"You already belong to this group" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [alert show];
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    GroupTableViewCell  *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupTableViewCell" forIndexPath:indexPath];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

@end
