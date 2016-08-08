//
//  GroupDetailViewController.m
//  Voices
//
//  Created by John Bogil on 7/5/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "PolicyDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIFont+voicesFont.h"
#import "UIColor+voicesColor.h"
#import "VoicesConstants.h"
#import "PolicyPosition.h"

@import Firebase;

@interface GroupDetailViewController ()  <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *followGroupButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *policyPositionsLabel;
@property (weak, nonatomic) IBOutlet UITextView *groupDescriptionTextview;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *policyPositionsRef;

@property (strong, nonatomic) NSMutableArray *listOfPolicyPositions;

@end

@implementation GroupDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    self.policyPositionsRef = [[self.groupsRef child:self.group.key]child:@"policyPositions"];
    
    [self configureTableView];
    [self fetchPolicyPositions];
    [self setFont];
    
    self.title = self.group.name;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];

    self.followGroupButton.layer.cornerRadius = kButtonCornerRadius;
    self.groupTypeLabel.text = self.group.groupType;
    self.groupDescriptionTextview.text = self.group.groupDescription;
    [self setGroupImageFromURL:self.group.groupImageURL];
    
    self.groupDescriptionTextview.contentInset = UIEdgeInsetsMake(-7.0,0.0,0,0.0);
    
    self.lineView.backgroundColor = [UIColor voicesOrange];
    self.lineView.layer.cornerRadius = kButtonCornerRadius;
    
    [self observeFollowStatus];

}

- (void)observeFollowStatus {
    
    [[[self.usersRef child:self.currentUserID] child:@"groups"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
       
        if (snapshot) {
            
            [self.followGroupButton setTitle:@"Followed ▾" forState:UIControlStateNormal];
        }
    }];
    
    [[[self.usersRef child:self.currentUserID] child:@"groups"] observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot) {
            
            [self.followGroupButton setTitle:@"Follow This Group" forState:UIControlStateNormal];
        }
    }];
    
    [self.followGroupButton.titleLabel setTextAlignment: NSTextAlignmentCenter];

}

- (void)setFont {
    
    self.groupDescriptionTextview.font = [UIFont voicesFontWithSize:17];
    self.groupTypeLabel.font = [UIFont voicesFontWithSize:17];
    self.followGroupButton.titleLabel.font = [UIFont voicesFontWithSize:21];
    self.policyPositionsLabel.font = [UIFont voicesBoldFontWithSize:17];
}

- (void)viewDidLayoutSubviews {
    [self.groupDescriptionTextview setContentOffset:CGPointZero animated:NO];
}

- (void)setGroupImageFromURL:(NSURL *)url {
    
    self.groupImageView.contentMode = UIViewContentModeScaleToFill;
    self.groupImageView.layer.cornerRadius = kButtonCornerRadius;
    self.groupImageView.clipsToBounds = YES;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
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
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:group.name message:@"You will now receive updates from this group" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
                    [alert show];
                }
            }];
            
            // Add group to user's subscriptions
            NSString *topic = [group.key stringByReplacingOccurrencesOfString:@" " withString:@""];
            [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/%@", topic]];
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

- (void)fetchPolicyPositions {
    
    __weak GroupDetailViewController *weakSelf = self;
    [self.policyPositionsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *policyPositionsDict = snapshot.value;
        NSMutableArray *policyPositionsArray = [NSMutableArray array];
        [policyPositionsDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            PolicyPosition *policyPosition = [[PolicyPosition alloc]initWithKey:key policyPosition:obj];
            [policyPositionsArray addObject:policyPosition];
        }];
        weakSelf.listOfPolicyPositions = [NSMutableArray arrayWithArray:policyPositionsArray];
        [weakSelf.tableView reloadData];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listOfPolicyPositions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.listOfPolicyPositions[indexPath.row]key];
    cell.textLabel.font = [UIFont voicesFontWithSize:19];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    PolicyDetailViewController *policyDetailViewController = (PolicyDetailViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier: @"PolicyDetailViewController"];
    policyDetailViewController.policyPosition = self.listOfPolicyPositions[indexPath.row];
    [self.navigationController pushViewController:policyDetailViewController animated:YES];

}

@end
