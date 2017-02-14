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
#import "GroupDescriptionTableViewCell.h"
#import "PolicyPositionsDetailCell.h"
#import "GroupDetailTableViewCell.h"
@import Firebase;

@interface GroupDetailViewController ()

@property (weak, nonatomic)IBOutlet UITableView *tableView;
@property (nonatomic, weak)id<ExpandingCellDelegate>expandingCellDelegate;
@property (weak, nonatomic)id<FollowGroupDelegate>followGroupDelegate;
@property (nonatomic, nullable) UISelectionFeedbackGenerator *feedbackGenerator;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *policyPositionsRef;
@property (strong, nonatomic) NSMutableArray *listOfPolicyPositions;
@property (strong, nonatomic) NSString *followGroupStatus;


@end

@implementation GroupDetailViewController

- (void)dealloc {
    self.feedbackGenerator = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    self.policyPositionsRef = [[self.groupsRef child:self.group.key]child:@"policyPositions"];
    [self configureTableView];
    [self fetchPolicyPositions];
    [self configureTitleLabel];
    [self observeFollowGroupStatus];
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    NSOperatingSystemVersion version;
    version.majorVersion = 10;
    version.minorVersion = 0;
    version.patchVersion = 0;
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version]) {
        self.feedbackGenerator = [[UISelectionFeedbackGenerator alloc] init];;
        [self.feedbackGenerator prepare];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)configureTitleLabel {
    self.title = self.group.name;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    titleLabel.text = self.navigationItem.title;
    [titleLabel setAdjustsFontSizeToFitWidth:true];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.navigationItem.titleView = titleLabel;
}

- (void)setGroupImageFromURL:(NSURL *)url inCell:(GroupDetailTableViewCell *)cell {
    cell.groupImageView.contentMode = UIViewContentModeScaleToFill;
    cell.groupImageView.layer.cornerRadius = kButtonCornerRadius;
    cell.groupImageView.clipsToBounds = YES;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    [cell.groupImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        NSLog(@"Action image success");
        
        [UIView animateWithDuration:.25 animations:^{
            cell.groupImageView.image = image;
        }];
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Action image failure");
    }];
}

- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.expandingCellDelegate = self;
    self.followGroupDelegate = self;
    self.tableView.estimatedRowHeight = 150.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupDetailTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupDetailTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupDescriptionTableViewCell"bundle:nil]forCellReuseIdentifier:@"GroupDescriptionTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PolicyPositionsDetailCell" bundle:nil]  forCellReuseIdentifier:@"PolicyPositionsDetailCell"];
    [self.tableView setShowsVerticalScrollIndicator:false];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (void)observeFollowGroupStatus {
    if([[CurrentUser sharedInstance].listOfFollowedGroups containsObject:self.group] == true) {
        self.followGroupStatus = @"Following ▾";
    }else{
        self.followGroupStatus = @"Follow Group";

    }
}

- (void)followGroupStatusDidChange {
    if([self.followGroupStatus isEqualToString:@"Following ▾"] == true){
        self.followGroupStatus = @"Follow Group";
    }else{
        self.followGroupStatus = @"Following ▾";
    }
    [self.tableView reloadData];
}

#pragma mark - Firebase methods

- (IBAction)followGroupButtonDidPress {
    // Action originates in GroupDetailTableViewCell. When button is pressed the view calls this method via the followGroupDelegate
    [self.feedbackGenerator selectionChanged];
    
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
                                                  
                                                  self.followGroupStatus = @"Follow Group";
                                                  
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

// TODO: MOVE TO A TAKEACTION NETWORK MANAGER
- (void)fetchPolicyPositions {
    __weak GroupDetailViewController *weakSelf = self;
    [self.policyPositionsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *policyPositionsDict = snapshot.value;
        NSMutableArray *policyPositionsArray = [NSMutableArray array];
        [policyPositionsDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            PolicyPosition *policyPosition = [[PolicyPosition alloc]initWithKey:key policyPosition:obj];
            [policyPositionsArray addObject:policyPosition];
            NSLog(@"*** %@***", policyPosition.key);
        }];
        weakSelf.listOfPolicyPositions = [NSMutableArray arrayWithArray:policyPositionsArray];
        [weakSelf.tableView reloadData];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

#pragma mark - Expanding Cell Delegate

- (void)expandButtonDidPress:(GroupDescriptionTableViewCell *)cell {
    [self.tableView reloadData];
}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(20, 8, 300, 30);
    titleLabel.font = [UIFont voicesFontWithSize:20];
    titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    return titleLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *result;
    switch (section) {
        case 0:
            break;
        case 1:
            result = @"Policy Positions";
            break;
    }
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 2;
            break;
        case 1:
            numberOfRows = self.listOfPolicyPositions.count;
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    id cell;
    if (indexPath.section == 0){
        if(indexPath.row == 0){
            static NSString *CellIdentifier = @"GroupDetailTableViewCell";
            GroupDetailTableViewCell *groupDetailCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(groupDetailCell == nil){
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GroupDetailTableViewCell" owner:self options:nil];
                groupDetailCell = [topLevelObjects objectAtIndex:0];
            }
            groupDetailCell.selectionStyle = UITableViewCellSelectionStyleNone;
            groupDetailCell.followGroupDelegate = self;
            [groupDetailCell setTitleForButton:self.followGroupStatus];
            groupDetailCell.groupTypeLabel.text = self.group.groupType;
            [self setGroupImageFromURL:self.group.groupImageURL inCell:groupDetailCell];
            cell = groupDetailCell;
        }
        else if(indexPath.row == 1) {
            static NSString *CellIdentifier = @"GroupDescriptionTableViewCell";
            GroupDescriptionTableViewCell *groupDescriptionCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (groupDescriptionCell == nil) {
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GroupDescriptionTableViewCell" owner:self options:nil];
                groupDescriptionCell = [topLevelObjects objectAtIndex:0];
            }
            groupDescriptionCell.expandingCellDelegate = self;   // Expanding textview delegate
            [groupDescriptionCell configureTextViewWithContents:self.group.groupDescription];
            cell = groupDescriptionCell;
        }
    }
    else{
        static NSString *CellIdentifier = @"PolicyPositionsDetailCell";
        PolicyPositionsDetailCell *policyPositionsCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (policyPositionsCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PolicyPositionsDetailCell" owner:self options:nil];
            policyPositionsCell = [topLevelObjects objectAtIndex:0];
        }
        NSInteger row = [indexPath row];
        NSString *policy = [self.listOfPolicyPositions[row]key];
        policyPositionsCell.policyLabel.text = policy;
        policyPositionsCell.policyLabel.font = [UIFont voicesFontWithSize:19];
        policyPositionsCell.policyLabel.numberOfLines = 0;
        policyPositionsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell = policyPositionsCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result = 0.0;
    switch (indexPath.section) {
        case 0:
            if(indexPath.row == 0){
                result = 220;
                break;
            }else{
                result = UITableViewAutomaticDimension;
            }
        case 1:
            result = UITableViewAutomaticDimension;
        default:
            result = UITableViewAutomaticDimension;
            break;
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section > 0){
        // Allows centering of the nav bar title by making an empty back button
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:backButtonItem];
        UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
        PolicyDetailViewController *policyDetailViewController = (PolicyDetailViewController *)[takeActionSB instantiateViewControllerWithIdentifier: @"PolicyDetailViewController"];
        policyDetailViewController.policyPosition = self.listOfPolicyPositions[indexPath.row];
        [self.navigationController pushViewController:policyDetailViewController animated:YES];
    }
}

@end
