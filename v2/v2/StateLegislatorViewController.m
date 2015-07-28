//
//  StateLegislatorViewController.m
//  v2
//
//  Created by John Bogil on 7/27/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "StateLegislatorViewController.h"
#import "StateLegislator.h"
#import "RepManager.h"
@interface StateLegislatorViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation StateLegislatorViewController

- (void)viewWillAppear:(BOOL)animated{
    [self populateStateLegislators];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)populateStateLegislators {
    [[RepManager sharedInstance]createStateLegislators:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [RepManager sharedInstance].listofStateLegislators.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
        StateLegislator *stateLegislator = [RepManager sharedInstance].listofStateLegislators[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", stateLegislator.firstName, stateLegislator.lastName];
        if (stateLegislator.photo) {
            cell.imageView.image = stateLegislator.photo;
        }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
