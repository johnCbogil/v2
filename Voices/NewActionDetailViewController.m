//
//  NewActionDetailViewController.m
//  Voices
//
//  Created by John Bogil on 6/10/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailViewController.h"
#import "NewActionDetailTopTableViewCell.h"
#import "RepTableViewCell.h"
#import "RepsManager.h"

@interface NewActionDetailViewController () <UITableViewDelegate, UITableViewDataSource, ExpandActionDescriptionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listOfReps;

@end

// TODO: ONLY RELOAD NECESSARY CELL
// TODO:
@implementation NewActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    self.title = self.group.name;
    
    if (self.action.level == 0) {
        self.listOfReps = [RepsManager sharedInstance].fedReps;
    }
    else if (self.action.level == 1) {
        self.listOfReps = [RepsManager sharedInstance].stateReps;
    }
    else if (self.action.level == 2) {
        self.listOfReps = [RepsManager sharedInstance].localReps;
    }
}

- (void)configureTableView {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NewActionDetailTopTableViewCell" bundle:nil]forCellReuseIdentifier:@"NewActionDetailTopTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:kRepTableViewCell bundle:nil]forCellReuseIdentifier:kRepTableViewCell];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.allowsSelection = NO;
}

- (void)expandActionDescription:(NewActionDetailTopTableViewCell *)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0] ;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.listOfReps.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        NewActionDetailTopTableViewCell *cell = (NewActionDetailTopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NewActionDetailTopTableViewCell" forIndexPath:indexPath];
        [cell initWithAction:self.action andGroup:self.group];
        self.tableView.estimatedRowHeight = 150;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        cell.delegate = self;
        return cell;
    }
    else {
        
        RepTableViewCell *cell = (RepTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kRepTableViewCell forIndexPath:indexPath];
        [cell initWithRep:self.listOfReps[indexPath.row-1]];
        self.tableView.rowHeight = 140;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
