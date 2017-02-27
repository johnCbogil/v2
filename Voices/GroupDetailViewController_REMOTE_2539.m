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

#pragma mark - Follow Group methods 

- (void)observeFollowGroupStatus {
   
    if([self isUserFollowingGroup:self.group.key] == true) {
        
        self.followGroupStatus = @"Following ▾";
    }
    else{
        self.followGroupStatus = @"Follow Group";
    }
}

- (BOOL)isUserFollowingGroup:(NSString *)groupKey {
    
    BOOL result = false;
    
    NSMutableArray *list = [[CurrentUser sharedInstance].listOfFollowedGroups copy];
    
    for (Group *group in list) {
        if ([groupKey isEqualToString:group.key]) {
            result = true;
            break;
        }
        else {
            result = false;
        }
    }
    return result;
}

- (void)followGroup {
    
    self.followGroupStatus = @"Following ▾";
    [self.tableView reloadData];
}

- (void)unFollowGroup {
    
    self.followGroupStatus = @"Follow Group";
    [self.tableView reloadData];
}

#pragma mark - Firebase methods

- (IBAction)followGroupButtonDidPress {
    
    // Action originates in GroupDetailTableViewCell from followGroupButton via the followGroupDelegate
    
    [self.feedbackGenerator selectionChanged];
    
    // TODO: ASK FOR NOTI PERMISSION FROM STPOPUP BEFORE ASKING FOR PERMISSION
    UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    NSString *groupKey = self.group.key;
    
    [[CurrentUser sharedInstance]followGroup:groupKey WithCompletion:^(BOOL isUserFollowingGroup) {
        
        if (!isUserFollowingGroup) {
            
            // Reflect follow status in UI
            [self followGroup];
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
                                                  
                                                  // Reflect follow status in UI
                                                  [self unFollowGroup];
                                                  
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
        }];
        weakSelf.listOfPolicyPositions = [NSMutableArray arrayWithArray:policyPositionsArray];
        [weakSelf.tableView reloadData];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

#pragma mark - Expanding Cell

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
    
    if (indexPath.section == 0){
        if(indexPath.row == 0){
            static NSString *CellIdentifier = @"GroupDetailTableViewCell";
            GroupDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil){
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GroupDetailTableViewCell" owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.followGroupDelegate = self;
            [cell setTitleForFollowGroupButton:self.followGroupStatus];
            cell.groupTypeLabel.text = self.group.groupType;
            [self setGroupImageFromURL:self.group.groupImageURL inCell:cell];
            return cell;
        }
        else if(indexPath.row == 1) {
            static NSString *CellIdentifier = @"GroupDescriptionTableViewCell";
            GroupDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GroupDescriptionTableViewCell" owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            cell.expandingCellDelegate = self;   // Expanding textview delegate
            [cell configureTextViewWithContents:self.group.groupDescription];
            return cell;
        }
    }
    else{
        static NSString *CellIdentifier = @"PolicyPositionsDetailCell";
        PolicyPositionsDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PolicyPositionsDetailCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        NSString *policy = [self.listOfPolicyPositions[indexPath.row]key];
        cell.policyLabel.text = policy;
        cell.policyLabel.font = [UIFont voicesFontWithSize:19];
        cell.policyLabel.numberOfLines = 0;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat result = UITableViewAutomaticDimension;
    
    if((indexPath.section == 0) && (indexPath.row == 0)){
        result = 220.0f;
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
