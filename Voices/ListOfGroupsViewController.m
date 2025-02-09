//
//  ListOfGroupsViewController.m
//  Voices
//
//  Created by John Bogil on 4/20/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ListOfGroupsViewController.h"

#import "CurrentUser.h"
#import "Group.h"
#import "GroupDetailViewController.h"
#import "GroupTableViewCell.h"
#import "TakeActionViewController.h"
#import "FirebaseManager.h"

@interface ListOfGroupsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *listOfGroups;
@property (strong, nonatomic) NSArray *listOfFollowedGroups;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *emptyStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *megaphoneEmojiLabel;

@end

@implementation ListOfGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self createActivityIndicator];
    [self configureSegmentedControl];
    [self configureEmptyStateLabel];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.segmentedControl.selectedSegmentIndex) {
        [self fetchAllGroups];
    }
}

- (void)configureEmptyStateLabel {
    
    self.emptyStateLabel.hidden = YES;
    self.megaphoneEmojiLabel.hidden = YES;

    if (self.segmentedControl.selectedSegmentIndex) {
        return;
    }
    
    if ([CurrentUser sharedInstance].listOfFollowedGroups.count) {
        self.emptyStateLabel.hidden = YES;
        self.megaphoneEmojiLabel.hidden = YES;
    }
    else {
        self.emptyStateLabel.hidden = NO;
        self.megaphoneEmojiLabel.hidden = NO;
    }
    
    self.emptyStateLabel.font = [UIFont voicesFontWithSize:23];
    self.megaphoneEmojiLabel.font = [UIFont voicesFontWithSize:46];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:@"You don't follow any groups right now. Select the All Groups tab to see groups and amplify your voice."];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor voicesOrange] range:NSMakeRange(49, 11)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont voicesBoldFontWithSize:23] range:NSMakeRange(49, 11)];
    self.emptyStateLabel.attributedText = attributedString;
    
    self.emptyStateLabel.numberOfLines = 0;
}

- (void)configureSegmentedControl {
    
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"My Groups",@"All Groups"]];
    self.navigationItem.titleView = self.segmentedControl;
    
    if ([CurrentUser sharedInstance].listOfFollowedGroups.count) {
        self.segmentedControl.selectedSegmentIndex = 0;
        [self fetchMyGroups];

    }
    else {
        self.segmentedControl.selectedSegmentIndex = 1;
        [self fetchAllGroups];

    }
    [self.segmentedControl addTarget:self action:@selector(segmentControlDidChangeValue) forControlEvents:UIControlEventValueChanged];
}

- (void)segmentControlDidChangeValue {
    
    [self configureEmptyStateLabel];
    
    if (self.segmentedControl.selectedSegmentIndex) {
        
        [self fetchAllGroups];
    }
    else {
        
        [self fetchMyGroups];
    }
}

- (void)configureTableView {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupTableViewCell"];
}

- (void)createActivityIndicator {
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.color = [UIColor grayColor];
    self.activityIndicatorView.center=self.view.center;
    [self.view addSubview:self.activityIndicatorView];
}

- (void)toggleActivityIndicatorOn {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView startAnimating];
    });
}

- (void)toggleActivityIndicatorOff {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
    });
}

#pragma mark - Firebase methods

- (void)fetchAllGroups {
    
    [self toggleActivityIndicatorOn];
    __weak ListOfGroupsViewController *weakSelf = self;
    [[FirebaseManager sharedInstance] fetchAllGroupsWithCompletion:^(NSArray *groups) {
        
        weakSelf.listOfGroups = [NSMutableArray arrayWithArray:groups];
        [weakSelf.tableView reloadData];
        [self toggleActivityIndicatorOff];
        
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}

- (void)fetchMyGroups {
    
    [self toggleActivityIndicatorOn];
    __weak ListOfGroupsViewController *weakSelf = self;
    [[FirebaseManager sharedInstance] fetchFollowedGroupsForCurrentUserWithCompletion:^(NSArray *listOfFollowedGroups) {
        
        weakSelf.listOfGroups = [CurrentUser sharedInstance].listOfFollowedGroups;
        [weakSelf.tableView reloadData];
        [self configureEmptyStateLabel];
        [self toggleActivityIndicatorOff];

    } onError:^(NSError *error) {
       [error localizedDescription];
    }];
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listOfGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GroupTableViewCell  *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupTableViewCell" forIndexPath:indexPath];
    [cell initWithGroup:self.listOfGroups[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Allows centering of the nav bar title by making an empty back button
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];

    UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
    GroupDetailViewController *groupDetailViewController = (GroupDetailViewController *)[takeActionSB instantiateViewControllerWithIdentifier:@"GroupDetailViewController"];
    groupDetailViewController.group = self.listOfGroups[indexPath.row];
    [self.navigationController pushViewController:groupDetailViewController animated:YES];
}

@end
