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
#import "GroupFollowTableViewCell.h"
#import "ActionTableViewCell.h"
#import "ActionDetailViewController.h"
#import "FirebaseManager.h"
#import "WebViewController.h"
#import "EmptyStateTableViewCell.h"

@interface GroupDetailViewController ()

@property (weak, nonatomic)IBOutlet UITableView *tableView;
@property (nonatomic, weak)id<ExpandingCellDelegate>expandingCellDelegate;
@property (weak, nonatomic)id<FollowGroupDelegate>followGroupDelegate;
@property (nonatomic, nullable) UISelectionFeedbackGenerator *feedbackGenerator;
@property (strong, nonatomic) NSMutableArray *listOfPolicyPositions;
@property (strong, nonatomic) NSString *followGroupStatus;
@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (strong, nonatomic) NSArray *listOfGroupActions;
@property (strong, nonatomic) NSString *const actionTBVReuse;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) NSString *websiteURL;
@end

@implementation GroupDetailViewController

- (void)dealloc {
    self.feedbackGenerator = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self createActivityIndicator];
    [self fetchActions];
    [self configureTitleLabel];
    [self observeFollowGroupStatus];
    [self configureHapticFeedback];
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(presentWebViewController:) name:@"presentWebViewControllerForGroupDetail" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    
    [self.tableView reloadData];
}

- (void)configureHapticFeedback {
    
    NSOperatingSystemVersion version;
    version.majorVersion = 10;
    version.minorVersion = 0;
    version.patchVersion = 0;
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version]) {
        self.feedbackGenerator = [[UISelectionFeedbackGenerator alloc] init];;
        [self.feedbackGenerator prepare];
    }
}

- (void)configureTitleLabel {
    
    self.title = self.group.name;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    titleLabel.text = self.navigationItem.title;
    [titleLabel setAdjustsFontSizeToFitWidth:true];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.navigationItem.titleView = titleLabel;
}

- (void)configureSegmentedControl {
    
    NSArray *items = @[@"Issues", @"Actions"];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:items];
    self.segmentControl.tintColor = [UIColor voicesOrange];
    [self.segmentControl addTarget:self action:@selector(segmentControlDidChangeValue) forControlEvents:UIControlEventValueChanged];
    [self.segmentControl setSelectedSegmentIndex:1];
    self.segmentControl.backgroundColor = [UIColor whiteColor];
    self.segmentControl.layer.cornerRadius = kButtonCornerRadius;
    [self.segmentControl setTitleTextAttributes:@{NSFontAttributeName : [UIFont voicesFontWithSize:19]} forState:UIControlStateNormal];
}

- (void)configureGroupImageFromURL:(NSURL *)url inCell:(GroupFollowTableViewCell *)cell {
    
    cell.groupImageView.contentMode = UIViewContentModeScaleToFill;
    cell.groupImageView.layer.cornerRadius = kButtonCornerRadius;
    cell.groupImageView.clipsToBounds = YES;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    [cell.groupImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        
        [UIView animateWithDuration:.25 animations:^{
            cell.groupImageView.image = image;
        }];
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        
    }];
}

- (void)configureTableView {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.expandingCellDelegate = self;
    self.followGroupDelegate = self;
    self.tableView.estimatedRowHeight = 150.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerNib:[UINib nibWithNibName:kGroupFollowTableViewCell bundle:nil]forCellReuseIdentifier:kGroupFollowTableViewCell];
    [self.tableView registerNib:[UINib nibWithNibName:kGroupDescriptionTableViewCell bundle:nil]forCellReuseIdentifier:kGroupDescriptionTableViewCell];
    [self.tableView registerNib:[UINib nibWithNibName:kPolicyPositionsDetailCell bundle:nil]  forCellReuseIdentifier:kPolicyPositionsDetailCell];
    [self.tableView registerNib:[UINib nibWithNibName:kActionCellReuse bundle:nil] forCellReuseIdentifier:kActionCellReuse];
    [self.tableView registerNib:[UINib nibWithNibName:kEmptyStateTableViewCell  bundle:nil] forCellReuseIdentifier: kEmptyStateTableViewCell];
    [self.tableView setShowsVerticalScrollIndicator:false];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.delaysContentTouches = YES;
}

- (void)presentWebViewController:(NSNotification *)notification {
    
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    WebViewController *webViewController = (WebViewController *)[repsSB instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = notification.object;
    webViewController.title = @"TAKE ACTION";
    webViewController.url = [NSURL URLWithString:self.group.website];
    self.navigationItem.title = @"";
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - Indicator

- (void)createActivityIndicator {
    
    self.indicatorView = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.color = [UIColor grayColor];
    self.indicatorView.frame = CGRectMake(0, 0, 30.0f, 30.0f);
    self.indicatorView.hidden = false;
    self.indicatorView.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:self.indicatorView];
    
    NSLayoutConstraint *horizontalConstraint = [self.indicatorView.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor];
    NSLayoutConstraint *verticalConstraint = [self.indicatorView.centerYAnchor constraintEqualToAnchor:self.view.bottomAnchor constant: -self.view.frame.size.height/6];
    NSArray *constraints = [[NSArray alloc]initWithObjects:horizontalConstraint, verticalConstraint, nil];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)toggleActivityIndicatorOn {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView startAnimating];
    });
}

- (void)toggleActivityIndicatorOff {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView stopAnimating];
    });
}

#pragma mark - Follow Group methods

- (void)observeFollowGroupStatus {
    
    if ([self isUserFollowingGroup:self.group.key] == true) {
        
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

- (void)askForNotificationAuth {
    
    NSString *notificationMessage = [NSString stringWithFormat:@"Enable action notifications from %@?", self.group.name];
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:notificationMessage
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *button0 = [UIAlertAction
                              actionWithTitle:@"Maybe later"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {}];
    
    UIAlertAction *button1 = [UIAlertAction
                              actionWithTitle:@"Yes"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  
                                  UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
                                  UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
                                  [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                                  [[UIApplication sharedApplication] registerForRemoteNotifications];
                                  
                              }];
    
    [alert addAction:button0];
    [alert addAction:button1];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Firebase methods

- (IBAction)followGroupButtonDidPress {
    
    // Action originates in GroupFollowTableViewCell from followGroupButton via the followGroupDelegate
    
    [self.feedbackGenerator selectionChanged];
    
    if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications] && ![self isUserFollowingGroup:self.group.key]) {
        
        [self askForNotificationAuth];
    }
    
    NSString *groupKey = self.group.key;
    
    __weak typeof(self) weakSelf = self;
    [[FirebaseManager sharedInstance]followGroup:groupKey withCompletion:^(BOOL isUserFollowingGroup) {
        
        if (!isUserFollowingGroup) {
            
            // Reflect follow status in UI
            [weakSelf followGroup];
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
                                          [[FirebaseManager sharedInstance]removeGroup:weakSelf.group];
                                          
                                          [[FirebaseManager sharedInstance] fetchGroupWithKey:weakSelf.group.key withCompletion:^(Group *group) {
                                              if (!group) {
                                                  [weakSelf unFollowGroup];
                                              }
                                          } onError:^(NSError *error) {
                                              
                                          }];
                                          // read the value once to see if group key exists
                                      }];
            
            [alert addAction:button0];
            [alert addAction:button1];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } onError:^(NSError *error) {
        [error localizedDescription];
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
    
    if (!self.segmentControl) {
        [self configureSegmentedControl];
    }
    return self.segmentControl;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        return 40.0f;
    }
    else return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    BOOL isActionsTabSelected = self.segmentControl.selectedSegmentIndex;
    BOOL isSectionEqualToList = section;
    
    if (!isSectionEqualToList) {
        return 2;
    }
    else {
        if (isActionsTabSelected) {
            if (self.listOfGroupActions.count >= 1) {
                return self.listOfGroupActions.count;
            }
            else {
                return 1;
            }
            
        }
        else {
            return self.listOfPolicyPositions.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    BOOL isPolicyOrActionCellSection = indexPath.section;
    BOOL isActionsTabSelected = self.segmentControl.selectedSegmentIndex;

    
    if (!isPolicyOrActionCellSection) {
        
        if (indexPath.row == 0){
            
            NSString *cellIdentifier = kGroupFollowTableViewCell;
            GroupFollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if(cell == nil){
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:kGroupFollowTableViewCell owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            cell.followGroupDelegate = self;
            [cell setTitleForFollowGroupButton:self.followGroupStatus];
            cell.groupTypeLabel.text = self.group.groupType;
            [cell.websiteButton setTitle:@"Visit website" forState:UIControlStateNormal];
            [self configureGroupImageFromURL:self.group.groupImageURL inCell:cell];
            return cell;
        }
        else if(indexPath.row == 1) {
            NSString *cellIdentifier = kGroupDescriptionTableViewCell;
            GroupDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:kGroupDescriptionTableViewCell owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            cell.expandingCellDelegate = self;   // Expanding textview delegate
            [cell configureTextViewWithContents:self.group.groupDescription];
            return cell;
        }
    }
    else {
        if (!isActionsTabSelected) {
            
                if (self.listOfPolicyPositions.count == 0) {
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                    NSString *cellIdentifier = kEmptyStateTableViewCell ;
                    EmptyStateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
                    if (cell == nil) {
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:kEmptyStateTableViewCell  owner:self options:nil];
                        cell = [topLevelObjects objectAtIndex: 0];
                    }
                    cell.emptyStateLabel.font = [UIFont voicesFontWithSize:19];
                    cell.emptyStateLabel.numberOfLines = 0;
                    cell.emptyStateLabel.text = @"This group hasn't listed any policy positions yet.";
                    cell.emptyStateLabel.textAlignment = NSTextAlignmentCenter;
                    return cell;
                } else {
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                    NSString *cellIdentifier = kPolicyPositionsDetailCell;
                    PolicyPositionsDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                    if (cell == nil) {
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:kPolicyPositionsDetailCell owner:self options:nil];
                        cell = [topLevelObjects objectAtIndex:0];
                    }
                    NSString *policy = [self.listOfPolicyPositions[indexPath.row]key];
                    cell.policyLabel.text = policy;
                    cell.policyLabel.font = [UIFont voicesFontWithSize:19];
                    cell.policyLabel.numberOfLines = 0;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
            }
        else {
                if (self.listOfGroupActions.count == 0) {
                    NSString *cellIdentifier = kEmptyStateTableViewCell ;
                    EmptyStateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
                    if (cell == nil) {
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:kEmptyStateTableViewCell  owner:self options:nil];
                        cell = [topLevelObjects objectAtIndex: 0];
                    }
                    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                    cell.emptyStateLabel.font = [UIFont voicesFontWithSize:19];
                    cell.emptyStateLabel.numberOfLines = 0;
                    cell.emptyStateLabel.text = @"This group hasn’t sent any actions yet.";
                    cell.emptyStateLabel.textAlignment = NSTextAlignmentCenter;
                    cell.userInteractionEnabled = NO;
                    return cell;
                } else {
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                    ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kActionCellReuse forIndexPath:indexPath];
                    if (cell == nil) {
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: kActionCellReuse owner:self options:nil];
                        cell = [topLevelObjects objectAtIndex: 0];
                    }
                    [cell initWithGroup:self.group andAction:self.listOfGroupActions[indexPath.row]];
                    return cell;
                }
            }
        }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section > 0){
        // Allows centering of the nav bar title by making an empty back button.
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:backButtonItem];
        switch (self.segmentControl.selectedSegmentIndex) {
            case 0: {
                UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
                PolicyDetailViewController *policyDetailViewController = (PolicyDetailViewController *)[takeActionSB instantiateViewControllerWithIdentifier: @"PolicyDetailViewController"];
                policyDetailViewController.policyPosition = self.listOfPolicyPositions[indexPath.row];
                [self.navigationController pushViewController:policyDetailViewController animated:YES];
                break;
            }
            case 1: {
                ActionDetailViewController *actionDetailVC = (ActionDetailViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ActionDetailViewController"];
                actionDetailVC.action = self.listOfGroupActions[indexPath.row];
                actionDetailVC.group = self.group;
                [self.navigationController pushViewController:actionDetailVC animated:true];
            }
            default:
                break;
        }
    }
}

#pragma mark - Segment Control

- (void)segmentControlDidChangeValue {
    if (self.segmentControl.selectedSegmentIndex == 1 && self.listOfGroupActions.count == 0) {
        
        [self fetchActions];
    }
    else if (self.segmentControl.selectedSegmentIndex == 0) {
        
        [self fetchPolicyPositions];
    }
    [self toggleActivityIndicatorOff];
    [self.tableView reloadData];
}

- (void)fetchActions {
    
    [self toggleActivityIndicatorOn];
    
    [CurrentUser sharedInstance].listOfActions = @[].mutableCopy;
    [[FirebaseManager sharedInstance] fetchActionsForGroup:self.group withCompletion:^(NSArray *listOfActions) {
        
        [self toggleActivityIndicatorOff];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.listOfGroupActions = [listOfActions sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
        
        [self.tableView reloadData];
    }];
    
    
}

- (void)fetchPolicyPositions {
    
    [self toggleActivityIndicatorOn];
    
    [[FirebaseManager sharedInstance] fetchPolicyPositionsForGroup:self.group withCompletion:^(NSArray *positions) {
        
        [self toggleActivityIndicatorOff];
        self.listOfPolicyPositions = [NSMutableArray arrayWithArray:positions];
        [self.tableView reloadData];
    } onError:^(NSError *error) {
        
    }];
    [self.tableView reloadData];
    [self toggleActivityIndicatorOff];
}

@end
