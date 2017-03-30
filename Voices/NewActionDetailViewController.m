//
//  NewActionDetailViewController.m
//  Voices
//
//  Created by John Bogil on 3/20/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailViewController.h"
#import "NewActionDetailTopTableViewCell.h"
#import "NewActionDetailMiddleTableViewCell.h"
#import "NewActionDetailBottomTableViewCell.h"
#import "SearchViewController.h"
#import "LocationService.h"
#import "RepsManager.h"

@interface NewActionDetailViewController () <UITableViewDelegate, UITableViewDataSource, SelectRepDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation NewActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.group.name;
    [self configureTableview];
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (homeAddress) {
        [self fetchRepsForHomeAddress:homeAddress];
    }
    else {
        // TURN ON EMPTY STATE
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSearchViewController) name:@"presentSearchViewController" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (homeAddress) {
        [self fetchRepsForHomeAddress:homeAddress];
    }
    else {
        // TURN ON EMPTY STATE
    }
}

- (void)configureTableview {
    
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 300;
    self.tableview.separatorColor = [UIColor clearColor];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview registerNib:[UINib nibWithNibName:@"NewActionDetailTopTableViewCell" bundle:nil]forCellReuseIdentifier:@"NewActionDetailTopTableViewCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"NewActionDetailMiddleTableViewCell" bundle:nil]forCellReuseIdentifier:@"NewActionDetailMiddleTableViewCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"NewActionDetailBottomTableViewCell" bundle:nil]forCellReuseIdentifier:@"NewActionDetailBottomTableViewCell"];
}

- (void)fetchRepsForHomeAddress:(NSString *)address {
    
    [[LocationService sharedInstance]getCoordinatesFromSearchText:address withCompletion:^(CLLocation *locationResults) {
        
        if (self.action.level == 0) {
            [[RepsManager sharedInstance]createFederalRepresentativesFromLocation:locationResults WithCompletion:^{
                NSLog(@"%@", locationResults);
                [self.tableview reloadData];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
        else if (self.action.level == 1) {
            [[RepsManager sharedInstance]createStateRepresentativesFromLocation:locationResults WithCompletion:^{
                [self.tableview reloadData];
            } onError:^(NSError *error) {
                [error localizedDescription];
            }];
        }
        else if (self.action.level == 2) {
            [[RepsManager sharedInstance]createNYCRepsFromLocation:locationResults];
            [self.tableview reloadData];
        }
    } onError:^(NSError *googleMapsError) {
        NSLog(@"%@", [googleMapsError localizedDescription]);
    }];
}

#pragma mark - UITableView Delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        NewActionDetailTopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewActionDetailTopTableViewCell"];
        [cell initWithAction:self.action andGroup:self.group];
        return cell;
    }
    else if (indexPath.row == 1) {
        NewActionDetailMiddleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewActionDetailMiddleTableViewCell"];
        return cell;
    }
    else {
        NewActionDetailBottomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewActionDetailBottomTableViewCell"];
        cell.delegate = self;
        cell.descriptionTextView.delegate = self;
        [cell initWithAction:self.action];
        return cell;
    }
}

- (void)sendRepToViewController:(Representative *)rep {
    NSLog(@"%@",rep.fullName);
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.tableview beginUpdates];
    [self.tableview endUpdates];
}

#pragma mark - Presentation Controllers

- (void)presentSearchViewController {
    
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    SearchViewController *searchViewController = (SearchViewController *)[repsSB instantiateViewControllerWithIdentifier:@"SearchViewController"];
    
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:searchViewController animated:YES];

}

@end
