//
//  GroupOnboardingViewController.m
//  Voices
//
//  Created by John Bogil on 10/4/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "GroupOnboardingViewController.h"
#import "FirebaseManager.h"
#import "GroupTableViewCell.h"
#import "GroupDetailViewController.h"
#import "TabBarViewController.h"
#import "CurrentUser.h"

@interface GroupOnboardingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *listOfGroups;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;

@end

@implementation GroupOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.hidden = NO;
    self.title = @"Join Groups";
    [self configureTableView];
    [self configureInstructionLabel];
    [self fetchAllGroups];
    [self configureContinueButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)fetchAllGroups {
    
    __weak GroupOnboardingViewController *weakSelf = self;
    [[FirebaseManager sharedInstance] fetchAllGroupsWithCompletion:^(NSArray *groups) {
        
        weakSelf.listOfGroups = [NSMutableArray arrayWithArray:groups];
        [weakSelf.tableview reloadData];
        
    } onError:^(NSError *error) {
        
    }];
}

- (void)configureContinueButton {
    
    if ([CurrentUser sharedInstance].listOfFollowedGroups.count > 0) {
        self.continueButton.titleLabel.text = @"Continue";
    }
    else {
        self.continueButton.titleLabel.text = @"Join later";
    }
}

- (void)configureInstructionLabel {
    
    self.instructionLabel.text = @"Actions are more effective when taken with others.";
    self.instructionLabel.font = [UIFont voicesFontWithSize:19];
    self.instructionLabel.numberOfLines = 0;
}

- (void)configureTableView {
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor whiteColor];
    [self.tableview registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil] forCellReuseIdentifier:@"GroupTableViewCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listOfGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GroupTableViewCell  *cell = (GroupTableViewCell *)[self.tableview dequeueReusableCellWithIdentifier:@"GroupTableViewCell" forIndexPath:indexPath];
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

- (IBAction)continueButtonDidPress:(id)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    TabBarViewController *tabVC = (TabBarViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"TabBarViewController"];
    tabVC.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:tabVC animated:YES];
}
@end
