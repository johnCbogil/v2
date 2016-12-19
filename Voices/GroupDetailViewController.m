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
#import "PolicyPosition.h"
#import "CurrentUser.h"

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
    self.groupImageView.backgroundColor = [UIColor clearColor];
    self.lineView.backgroundColor = [UIColor voicesOrange];
    self.lineView.layer.cornerRadius = kButtonCornerRadius;
    
    [self observeFollowStatus];
}

- (void)observeFollowStatus {
    
    [[[[self.usersRef child:[FIRAuth auth].currentUser.uid] child:@"groups"]child:self.group.key] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.value != [NSNull null]) {
            
            if ([self.followGroupButton.titleLabel.text isEqualToString:@"Following ▾"]) {
                [self.followGroupButton setTitle:@"Follow Group" forState:UIControlStateNormal];
            }
            else {
                [self.followGroupButton setTitle:@"Following ▾" forState:UIControlStateNormal];
            }
        }
    }];
    
    [self.followGroupButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
}

- (void)setFont {
    
    self.groupDescriptionTextview.font = [UIFont voicesFontWithSize:17];
    self.groupTypeLabel.font = [UIFont voicesFontWithSize:17];
    self.followGroupButton.titleLabel.font = [UIFont voicesFontWithSize:21];
    self.policyPositionsLabel.font = [UIFont voicesMediumFontWithSize:17];
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

        [UIView animateWithDuration:.25 animations:^{
            self.groupImageView.image = image;
        }];
        
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
    
    // TODO: ASK FOR NOTI PERMISSION FROM STPOPUP BEFORE ASKING FOR PERMISSION
    UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    
    NSString *groupKey = self.group.key;

    [[CurrentUser sharedInstance]followGroup:groupKey WithCompletion:^(BOOL isUserFollowingGroup) {
        
        if (!isUserFollowingGroup) {
            
            NSLog(@"User subscribed to %@", groupKey);
        }
        else {
            
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                        message:@"Would you like to stop supporting this group?"
                                        preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *button0 = [UIAlertAction
                                      actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleCancel
                                      handler:^(UIAlertAction * action)
                                      {}];
            
            UIAlertAction *button1 = [UIAlertAction
                                      actionWithTitle:@"Unfollow"
                                      style:UIAlertActionStyleDestructive
                                      handler:^(UIAlertAction * action) {
                                          
                                          // Remove group
                                          [[CurrentUser sharedInstance]removeGroup:self.group];
                                          
                                          // read the value once to see if group key exists
                                          [[[[self.usersRef child:[FIRAuth auth].currentUser.uid] child:@"groups"]child:self.group.key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                              if (snapshot.value == [NSNull null]) {
                                                  
                                                  [self.followGroupButton setTitle:@"Follow Group" forState:UIControlStateNormal];
                                                  
                                              }
                                          } withCancelBlock:^(NSError * _Nonnull error) {
                                              NSLog(@"%@", error.localizedDescription);
                                          }];
                                      }];
            
            [alert addAction:button0];
            [alert addAction:button1];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } onError:^(NSError *error) {
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
    
    // Allows centering of the nav bar title by making an empty back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];

    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    PolicyDetailViewController *policyDetailViewController = (PolicyDetailViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier: @"PolicyDetailViewController"];
    policyDetailViewController.policyPosition = self.listOfPolicyPositions[indexPath.row];
    [self.navigationController pushViewController:policyDetailViewController animated:YES];
    
}

@end
