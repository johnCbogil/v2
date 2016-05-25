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

NSString * const kFirebaseRefUsers = @"users";
NSString * const kFirebaseRefGroups = @"groups";
NSString * const kFirebaseRefUserBarryO = @"BarryO/groups/ACLU";

/*
 https://www.firebase.com/docs/ios/guide/structuring-data.html
 http://jsfiddle.net/firebase/6dzys/embedded/result,js/
 */

@interface ListOfAdvocacyGroupsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *listOfAdvocacyGroups;
@end

@implementation ListOfAdvocacyGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select A Group To Follow";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"AdvocacyGroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"AdvocacyGroupTableViewCell"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    //    Firebase *rootRef = [[Firebase alloc] initWithUrl:@"https://voices-430ae.firebaseio.com/"];
    //    Firebase *usersRef = [rootRef childByAppendingPath:@"users"];
    //    Firebase *groupsRef = [rootRef childByAppendingPath:@"groups"];
    
    FIRDatabaseReference *rootRef = [[FIRDatabase database] reference];
    FIRDatabaseReference *userRef = [rootRef child:kFirebaseRefUsers];
    FIRDatabaseReference *groupsRef = [rootRef child:kFirebaseRefGroups];
    
    // see if BarryO is in the 'ACLU' group
    //    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://voices-430ae.firebaseio.com/users/BarryO/groups/ACLU"];
    //    [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
    //        NSString *result = snapshot.value == [NSNull null] ? @"is not" : @"is";
    //        NSLog(@"BarryO %@ a member of aclu group", result);
    //    }];
    
    FIRDatabaseReference *obamaRef = [userRef child:kFirebaseRefUserBarryO];
    [obamaRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *result = snapshot.value == [NSNull null] ? @"is not" : @"is";
        NSLog(@"BarryO %@ a member of aclu group", result);
    } withCancelBlock:^(NSError * _Nonnull error) {
        
    }];
    
    
    // fetch a list of BarryO groups
    //    [groupsRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
    //        // for each group, fetch the name and print it
    //        NSString *groupKey = snapshot.key;
    //        NSString *groupPath = [NSString stringWithFormat:@"groups/%@/name", groupKey];
    //        [[rootRef childByAppendingPath:groupPath] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
    //            NSLog(@"BarryO is a member of this group: %@", snapshot.value);
    //        }];
    //    }];
    [groupsRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // for each group, fetch the name and print it
        NSString *groupKey = snapshot.key;
        NSString *groupPath = [NSString stringWithFormat:@"groups/%@/name", groupKey];
        [[rootRef child:groupPath] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSLog(@"BarryO is a member of this group: %@", snapshot.value);
        }];        
    }];
    
    
    // Create a new user named "DCheney"
    
}

- (void)retrieveAdovacyGroups {
    
    
}

//- (void)followAdovacyGroup:(PFObject*)object {

//}


#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listOfAdvocacyGroups.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AdvocacyGroupTableViewCell  *cell = (AdvocacyGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AdvocacyGroupTableViewCell" forIndexPath:indexPath];
    [cell initWithData:[self.listOfAdvocacyGroups objectAtIndex:indexPath.row]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //  [self followAdovacyGroup:[self.listOfAdvocacyGroups objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
@end
