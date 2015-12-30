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
#import "LocationService.h"
#import "StateRepTableViewCell.h"
#import "UIFont+voicesFont.h"
@interface StateLegislatorViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation StateLegislatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"State Legislators";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[LocationService sharedInstance] startUpdatingLocation];
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadStateLegislatorTableData)
                                                 name:@"reloadStateLegislatorTableView"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefreshing) name:@"endRefreshing" object:nil];

    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StateRepTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"StateRepTableViewCell"];
    
    self.tableView.allowsSelection = NO;
    self.tableView.alpha = 0.0;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleZeroStateLabel" object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    @try{
        [[LocationService sharedInstance]removeObserver:self forKeyPath:@"currentLocation" context:nil];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pullToRefresh {
    [[LocationService sharedInstance] startUpdatingLocation];
    [[RepManager sharedInstance]createStateLegislatorsFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}
- (void)populateStateLegislatorsFromLocation:(CLLocation*)location {
    [[RepManager sharedInstance]createStateLegislatorsFromLocation:location WithCompletion:^{
        [UIView animateWithDuration:.25 animations:^{
            self.tableView.alpha = 1.0;
        }];
        [self.tableView reloadData];
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}

- (void)reloadStateLegislatorTableData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        [self populateStateLegislatorsFromLocation:[LocationService sharedInstance].currentLocation];
    }
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [RepManager sharedInstance].listofStateLegislators.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//        StateLegislator *stateLegislator = [RepManager sharedInstance].listofStateLegislators[indexPath.row];
//        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", stateLegislator.firstName, stateLegislator.lastName];
//        if (stateLegislator.photo) {
//            cell.imageView.image = [UIImage imageWithData:stateLegislator.photo];
//        }
//    return cell;
    
    StateRepTableViewCell *cell = (StateRepTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"StateRepTableViewCell" forIndexPath:indexPath];
    [cell initFromIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)presentCustomAlertWithMessage:(NSString *)message andTitle:(NSString*)title {
    CustomAlertViewController *customAlertViewController = [[UIStoryboard storyboardWithName:@"Info" bundle:nil] instantiateViewControllerWithIdentifier:@"customAlertViewController"];
    customAlertViewController.messageText = message;
    customAlertViewController.titleText = title;
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:customAlertViewController];
    popupController.cornerRadius = 10;
    
    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:17] } forState:UIControlStateNormal];
    
    [popupController presentInViewController:self];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

@end