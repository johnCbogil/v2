//
//  PolicyPositionsTableViewCell.m
//  Voices
//
//  Created by perrin cloutier on 1/6/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "PolicyPositionsTableViewCell.h"
#import "PolicyPositionsDetailCell.h"

@implementation PolicyPositionsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configureCellWithPolicyPositions:(NSMutableArray *)listOfPolicyPositions
{
    self.listOfPolicyPositions = listOfPolicyPositions;
    [self configureTableView];
}
//
//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andPolicyPositions:(NSMutableArray *)policyPositions
//{
//    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        
//        _listOfPolicyPositions = policyPositions; //commentsTableDataSource is property holding comments array
//        
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
//        //        [_tableView reloadData];
//        [self configureTableView];
//    }
//    return self;
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// from GroupDetailViewController
- (void)configureTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"PolicyPositionsDetailCell" bundle:nil]  forCellReuseIdentifier:@"PolicyPositionsDetailCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.tableView.estimatedRowHeight = 50.f;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView reloadData];
    
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listOfPolicyPositions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PolicyPositionsDetailCell";
    PolicyPositionsDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PolicyPositionsDetailCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.policyLabel.text = [self.listOfPolicyPositions[indexPath.row]key];
    cell.policyLabel.font = [UIFont voicesFontWithSize:19];
    cell.policyLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self presentPolicyDetailViewController:indexPath];
}

- (void)presentPolicyDetailViewController:(NSIndexPath *)indexPath
{
    [self.policyPositionsDelegate presentPolicyDetailViewController:indexPath];
}

@end
