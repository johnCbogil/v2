//
//  NewActionDetailViewController.m
//  Voices
//
//  Created by John Bogil on 6/10/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailViewController.h"

@interface NewActionDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NewActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)configureTableView {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NewActionDetailTopTableViewCell" bundle:nil]forCellReuseIdentifier:@"NewActionDetailTopTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NewActionDetailBottomTableViewCell" bundle:nil]forCellReuseIdentifier:@"NewActionDetailBottomTableViewCell"];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    return cell;
}

@end
