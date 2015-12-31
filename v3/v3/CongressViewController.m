//
//  ViewController.m
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "CongressViewController.h"
#import "LocationService.h"
#import "RepManager.h"
#import "Congressperson.h"
#import "StateLegislator.h"
#import <STPopup/STPopup.h>
#import "UIFont+voicesFont.h"

@implementation CongressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkCache];
    
    self.title = @"Congress";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadCongressTableData)
                                                 name:@"reloadCongressTableView"
                                               object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endRefreshing) name:@"endRefreshing" object:nil];
    
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CongresspersonTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"CongresspersonTableViewCell"];
    
    self.tableView.allowsSelection = NO;
    //self.tableView.alpha = 0.0;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"toggleZeroStateLabel" object:nil];
}

- (void)checkCache {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:@"savedArray"];
    if (dataRepresentingSavedArray != nil) {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        if (oldSavedArray != nil)
            [RepManager sharedInstance].listOfCongressmen = [[NSMutableArray alloc] initWithArray:oldSavedArray];
        self.tableView.alpha = 1.0;
        [self reloadCongressTableData];
    }
    else {
        [RepManager sharedInstance].listOfCongressmen = [[NSMutableArray alloc] init];
        [[LocationService sharedInstance] startUpdatingLocation];
    }
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
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pullToRefresh {
    [[LocationService sharedInstance] startUpdatingLocation];
    [[RepManager sharedInstance]createCongressmenFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}

- (void)populateCongressmenFromLocation:(CLLocation*)location {
    [[RepManager sharedInstance]createCongressmenFromLocation:location WithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.25 animations:^{
                self.tableView.alpha = 1.0;
            }];
            [self.tableView reloadData];
        });
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}

- (void)reloadCongressTableData{
    //NSLog(@"%@", [[[RepManager sharedInstance].listOfCongressmen objectAtIndex:0]firstName]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
    
}
 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        [self populateCongressmenFromLocation:[LocationService sharedInstance].currentLocation];
    }
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[RepManager sharedInstance].listOfCongressmen] forKey:@"savedArray"];
    return [RepManager sharedInstance].listOfCongressmen.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CongresspersonTableViewCell *cell = (CongresspersonTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CongresspersonTableViewCell" forIndexPath:indexPath];
    [cell initFromIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [[RepManager sharedInstance]assignInfluenceExplorerID:[RepManager sharedInstance].listOfCongressmen[indexPath.row] withCompletion:^{
//        [[RepManager sharedInstance]assignTopContributors:[RepManager sharedInstance].listOfCongressmen[indexPath.row] withCompletion:^{
//            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//            self.influenceExplorerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"influenceExplorerViewController"];
//            self.influenceExplorerVC.congressperson = [RepManager sharedInstance].listOfCongressmen[indexPath.row];
//            [self.navigationController pushViewController:self.influenceExplorerVC animated:YES];
//        } onError:^(NSError *error) {
//            [error localizedDescription];
//        }];
//    } onError:^(NSError *error) {
//        [error localizedDescription];
//    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
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