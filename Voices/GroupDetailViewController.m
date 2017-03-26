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

@end

@implementation GroupDetailViewController

- (void)dealloc {
    self.feedbackGenerator = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self createActivityIndicator];
    [self fetchPolicyPositions];
    [self configureTitleLabel];
    [self observeFollowGroupStatus];
    [self configureHapticFeedback];
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(presentWebViewController:) name:@"presentWebViewControllerForGroupDetail" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

- (void)setGroupImageFromURL:(NSURL *)url inCell:(GroupFollowTableViewCell *)cell {
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
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupFollowTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupFollowTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupDescriptionTableViewCell"bundle:nil]forCellReuseIdentifier:@"GroupDescriptionTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PolicyPositionsDetailCell" bundle:nil]  forCellReuseIdentifier:@"PolicyPositionsDetailCell"];
    [self.tableView registerNib:[UINib nibWithNibName:kActionCellReuse bundle:nil] forCellReuseIdentifier:kActionCellReuse];
    [self.tableView setShowsVerticalScrollIndicator:false];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)presentWebViewController:(NSNotification *)notification {
    
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    WebViewController *webViewController = (WebViewController *)[repsSB instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = notification.object;
    webViewController.title = @"TAKE ACTION";
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
    
    // Action originates in GroupFollowTableViewCell from followGroupButton via the followGroupDelegate
    
    [self.feedbackGenerator selectionChanged];
    
    // TODO: ASK FOR NOTI PERMISSION FROM STPOPUP BEFORE ASKING FOR PERMISSION
    UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    NSString *groupKey = self.group.key;
    
    __weak typeof(self) weakSelf = self;
    [[FirebaseManager sharedInstance]followGroup:groupKey withCompletion:^(BOOL isUserFollowingGroup) {
        
        if (!isUserFollowingGroup) {
            
            // Reflect follow status in UI
            [weakSelf followGroup];
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
                                          [[FirebaseManager sharedInstance]removeGroup:weakSelf.group];
                                          
                                          [[FirebaseManager sharedInstance] fetchGroupWithKey:weakSelf.group.key withCompletion:^(Group *group) {
                                              if (!group) {
                                                  [weakSelf unFollowGroup];
                                              }
                                          } onError:^(NSError *error) {
                                              NSLog(@"Error fetching group with key: %@. Error: %@", groupKey, error.localizedDescription);
                                          }];
                                          // read the value once to see if group key exists
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
    [self toggleActivityIndicatorOn];
    __weak GroupDetailViewController *weakSelf = self;
    [[FirebaseManager sharedInstance] fetchPolicyPositionsForGroup:self.group withCompletion:^(NSArray *positions) {
        [self toggleActivityIndicatorOff];
        weakSelf.listOfPolicyPositions = [NSMutableArray arrayWithArray:positions];
        [weakSelf.tableView reloadData];
    } onError:^(NSError *error) {
        NSLog(@"Error fetching policy position for group: %@. Error message: %@", self.group.name, error.localizedDescription);
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
    switch (section) {
        case 0:
            return nil;
        case 1: {
            if (!self.segmentControl) {
                NSArray *items = @[@"Issues", @"Actions"];
                self.segmentControl = [[UISegmentedControl alloc] initWithItems:items];
                self.segmentControl.tintColor = [UIColor voicesOrange];
                [self.segmentControl addTarget:self action:@selector(segmentControlDidChangeValue) forControlEvents:UIControlEventValueChanged];
                [self.segmentControl setSelectedSegmentIndex:0];
                self.segmentControl.backgroundColor = [UIColor whiteColor];
                self.segmentControl.layer.cornerRadius = kButtonCornerRadius;
                [self.segmentControl setTitleTextAttributes:@{NSFontAttributeName : [UIFont voicesFontWithSize:19]} forState:UIControlStateNormal];
            }
            return self.segmentControl;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0;
        case 1:
            return 40.0f;
    }
    return 40.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 2;
            break;
        case 1:
            switch (self.segmentControl.selectedSegmentIndex) {
                case 0:
                    numberOfRows = self.listOfPolicyPositions.count;
                    break;
                case 1:
                    numberOfRows = self.listOfGroupActions.count;
                    break;
            }
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (indexPath.section == 0){
        if(indexPath.row == 0){
            static NSString *CellIdentifier = @"GroupFollowTableViewCell";
            GroupFollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(cell == nil){
                // Load the top-level objects from the custom cell XIB.
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GroupFollowTableViewCell" owner:self options:nil];
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

        switch (self.segmentControl.selectedSegmentIndex) {
            case 0: {
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
            case 1: {
                ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kActionCellReuse forIndexPath:indexPath];
                [cell initWithGroup:self.group andAction:self.listOfGroupActions[indexPath.row]];
                return cell;
            }
        }
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
                ActionDetailViewController *actionDetailVC = (ActionDetailViewController*) [self.storyboard instantiateViewControllerWithIdentifier:@"ActionDetailViewController"];
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
        [[FirebaseManager sharedInstance] fetchActionsForGroup:self.group withCompletion:^(NSArray *listOfActions) {
            self.listOfGroupActions = [[listOfActions reverseObjectEnumerator] allObjects];
            [self.tableView reloadData];
        }];
    }
    [self.tableView reloadData];
}

@end
