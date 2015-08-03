//
//  InfluenceExplorerViewController.m
//  v2
//
//  Created by John Bogil on 7/28/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "InfluenceExplorerViewController.h"
#import "RepManager.h"

@interface InfluenceExplorerViewController ()

@end

@implementation InfluenceExplorerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Influence Explorer";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.congressperson.topIndustries.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.congressperson.topIndustries[indexPath.row]valueForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@",[self.congressperson.topIndustries[indexPath.row]valueForKey:@"amount"]];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
