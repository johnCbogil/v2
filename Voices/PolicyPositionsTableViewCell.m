//
//  PolicyPositionsTableViewCell.m
//  Voices
//
//  Created by perrin cloutier on 1/6/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "PolicyPositionsTableViewCell.h"

@implementation PolicyPositionsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier :(NSMutableArray *)listOfPolicyPositions{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _listOfPolicyPositions = listOfPolicyPositions; //commentsTableDataSource is property holding comments array
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //        [_tableView reloadData];
        [self configureTableView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// from GroupDetailViewController
- (void)configureTableView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.estimatedRowHeight = 50.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listOfPolicyPositions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.listOfPolicyPositions[indexPath.row]key];
    cell.textLabel.font = [UIFont voicesFontWithSize:19];
    cell.textLabel.numberOfLines = 0;
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
