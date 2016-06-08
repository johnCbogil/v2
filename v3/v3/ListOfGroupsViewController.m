//
//  ListOfGroupsViewController.h
//  Voices
//
//  Created by John Bogil on 4/20/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ListOfGroupsViewController.h"
#import "GroupTableViewCell.h"
#import "GroupsViewController.h"

@interface ListOfGroupsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *listOfGroups;
@end

@implementation ListOfGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Select A Group To Follow";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupTableViewCell"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    
    [self retrieveAdovacyGroups];
}

- (void)retrieveAdovacyGroups {
    PFQuery *query = [PFQuery queryWithClassName:@"AdvocacyGroups"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Retrieve Group Success");
            self.listOfGroups = [[NSMutableArray alloc]initWithArray:objects];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Retrieve Groups Error: %@", error);
        }
    }];
}

- (void)followAdovacyGroup:(PFObject*)object {
    [[PFInstallation currentInstallation]addUniqueObject:object.objectId forKey:@"channels"];
    NSLog(@"Group: %@", object);
    [[PFInstallation currentInstallation]saveInBackground];
    [object addUniqueObject:[PFUser currentUser].username forKey:@"followers"];
    
  // I DONT THINK I NEED THIS DELEGATE ACTUALLY
    // I NEED TO ADD TO SUPER'S "FOLLOWEDADGROUPS" ARRAY HERE SOMEHOW
    [self.delegate addItemViewController:self didFinishEnteringItem:object];
    
    
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            
            NSLog(@"Followed!");
            NSString *groupName = [object valueForKey:@"Name"];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:groupName message:@"You will now recieve calls to action from this group" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
        }
        else {
            NSLog(@"Follow Error: %@", error);
        }
    }];
}


#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listOfGroups.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        GroupTableViewCell  *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupTableViewCell" forIndexPath:indexPath];
        [cell initWithData:[self.listOfGroups objectAtIndex:indexPath.row]];
        return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self followAdovacyGroup:[self.listOfGroups objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
@end
