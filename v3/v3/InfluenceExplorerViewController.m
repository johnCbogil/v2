//
//  InfluenceExplorerViewController.m
//  v2
//
//  Created by John Bogil on 7/28/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "InfluenceExplorerViewController.h"
#import "RepManager.h"
#import "PageViewController.h"

@implementation InfluenceExplorerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Influence Explorer";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.congressperson.topContributors.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *contributor = self.congressperson.topContributors[indexPath.row];
    NSDictionary *contributorAttributes = contributor[@"@attributes"];
    cell.textLabel.text = [contributorAttributes valueForKey:@"org_name"];
    NSString *dollarAmount =  [self formatContributionTotal:[contributorAttributes objectForKey:@"total"]];
    cell.detailTextLabel.text = dollarAmount;
    return cell;
}

- (NSString*)formatContributionTotal:(NSString *)contributionTotal {
    
    NSNumberFormatter *currencyStyleFormatter = [[NSNumberFormatter alloc] init];
    [currencyStyleFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumberFormatter *nFromStringFormatter = [[NSNumberFormatter alloc] init];
    nFromStringFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [nFromStringFormatter numberFromString:contributionTotal];
    NSString *dollarAmount = [currencyStyleFormatter stringFromNumber:myNumber];
    
    return dollarAmount;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end