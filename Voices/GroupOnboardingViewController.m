//
//  GroupOnboardingViewController.m
//  Voices
//
//  Created by John Bogil on 10/4/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "GroupOnboardingViewController.h"
#import "FirebaseManager.h"

@interface GroupOnboardingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *listOfGroups;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end

@implementation GroupOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)fetchAllGroups {
    
    __weak GroupOnboardingViewController *weakSelf = self;
    [[FirebaseManager sharedInstance] fetchAllGroupsWithCompletion:^(NSArray *groups) {
        
        weakSelf.listOfGroups = [NSMutableArray arrayWithArray:groups];
        [weakSelf.tableview reloadData];
        
    } onError:^(NSError *error) {
        
    }];
}
- (void)configureTableView {
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell;
    return cell;
}

- (IBAction)skipButtonDidPress:(id)sender {
    
}

- (IBAction)continueButtonDidPress:(id)sender {
    
}
@end
