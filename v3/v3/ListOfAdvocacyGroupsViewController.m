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
#import <Firebase/Firebase.h>


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

    
    // Print all of the db data, db read rules are set to true
    Firebase *rootRef = [[Firebase alloc] initWithUrl:@"https://voices-430ae.firebaseio.com/"];
//    [myRootRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"%@", snapshot.value);
//    } withCancelBlock:^(NSError *error) {
//        NSLog(@"%@", error.description);
//    }];
    
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
