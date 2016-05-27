//
//  ListOfAdvocacyGroupsViewController.m
//  Voices
//
//  Created by John Bogil on 4/20/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ListOfAdvocacyGroupsViewController.h"
#import "AdvocacyGroupTableViewCell.h"
#import "AdvocacyGroupsViewController.h"
@import Firebase;

/*
 https://www.firebase.com/docs/ios/guide/structuring-data.html
 http://jsfiddle.net/firebase/6dzys/embedded/result,js/
 */

@interface ListOfAdvocacyGroupsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray <NSString *> *listOfGroups;
@property (strong, nonatomic) NSString *currentUserID;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;


@end

@implementation ListOfAdvocacyGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select A Group To Follow";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //    [self.tableView registerNib:[UINib nibWithNibName:@"AdvocacyGroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"AdvocacyGroupTableViewCell"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    
    //    // see if BarryO is in the 'ACLU' group
    //    FIRDatabaseReference *obamaRef = [self.usersRef child:kFirebaseRefUserBarryO];
    //    [obamaRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    //        NSString *result = snapshot.value == [NSNull null] ? @"is not" : @"is";
    //        NSLog(@"BarryO %@ a member of aclu group", result);
    //    } withCancelBlock:^(NSError * _Nonnull error) {
    //
    //    }];
    //
    //
    //    // fetch a list of BarryO groups
    //    [self.groupsRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    //        // for each group, fetch the name and print it
    //        NSString *groupKey = snapshot.key;
    //        NSString *groupPath = [NSString stringWithFormat:@"groups/%@/name", groupKey];
    //        [[self.rootRef child:groupPath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    //            NSLog(@"BarryO is a member of this group: %@", snapshot.value);
    //        }];
    //    }];
    
    
    [self userAuth];
    [self retrieveGroups];
    [self removeGroup];
    
}

- (void)userAuth {
   
}

- (void)retrieveGroups {
    __weak ListOfAdvocacyGroupsViewController *weakSelf = self;
    [self.groupsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *groups = snapshot.value;
        NSMutableArray *namesArray = @[].mutableCopy;
        [groups enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSDictionary *objDict = obj; //add dictOrNil macro
            NSString *name = objDict[@"name"];
            if (name.length > 0) {
                [namesArray addObject:name];
            }
        }];
        
        weakSelf.listOfGroups = [NSArray arrayWithArray:namesArray];
        [weakSelf.tableView reloadData];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)followGroup:(NSString *)groupName {
    
    // add group to user's groups
    [[[self.usersRef child:self.currentUserID]child:@"groups"] updateChildValues:@{groupName :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"write error: %@", error);
        }
    }];
    
    // add user to group's users
    [[[self.groupsRef child:@"ACLU"]child:@"followers"] updateChildValues:@{groupName :@1} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"write error: %@", error);
        }
    }];
    
}

- (void)removeGroup {
    
    // Remove group from user's groups
    [[[[self.usersRef child:self.currentUserID]child:@"groups"]child:@"tesgroup8"]removeValue];
    
    // Remove user from group's users
    [[[[self.groupsRef child:@"ACLU"]child:@"followers"]child:@"testFollower"]removeValue];
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listOfGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell  *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.listOfGroups[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self followGroup:self.listOfGroups[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

@end
