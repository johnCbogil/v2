//
//  GroupDetailViewController.m
//  Voices
//
//  Created by John Bogil on 7/5/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIFont+voicesFont.h"
#import "UIColor+voicesOrange.h"
#import "VoicesConstants.h"

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

@property (strong, nonatomic) NSArray *tempArray;

@end

@implementation GroupDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    
    [self configureTableView];
    
    self.title = self.group.name;
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];

    self.groupNameLabel.text = self.group.name;
    self.groupTypeLabel.text = self.group.groupType;
    self.groupDescriptionLabel.text = self.group.groupDescription;
    [self setGroupImageFromURL:self.group.groupImageURL];

    self.tempArray = @[@"Campaign Finance", @"Civil Liberties", @"Women's Healthcare", @"Affordable Housing", @"Gun Safety"];
    
}

- (void)setGroupImageFromURL:(NSURL *)url {
    
    self.groupImageView.contentMode = UIViewContentModeScaleToFill;
    self.groupImageView.layer.cornerRadius = kButtonCornerRadius;
    self.groupImageView.clipsToBounds = YES;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: @"MissingRepMale"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        NSLog(@"Action image success");
        self.groupImageView.image = image;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Action image failure");
    }];
}

- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupTableViewCell"];
}

#pragma mark - Firebase methods

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

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tempArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.tempArray[indexPath.row];
    return cell;
}

@end
