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
@interface CongressViewController ()
@end

@implementation CongressViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadCongressTableData)
                                                 name:@"reloadCongressTableView"
                                               object:nil];
    
    
    [[LocationService sharedInstance] startUpdatingLocation];
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CongresspersonTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"CongresspersonTableViewCell"];
    
    self.tableView.allowsSelection = NO;
    
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)reloadCongressTableData{
    NSLog(@"%@", [[[RepManager sharedInstance].listOfCongressmen objectAtIndex:0]firstName]);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    [self.refreshControl endRefreshing];
}
 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        [self populateCongressmenFromLocation:[LocationService sharedInstance].currentLocation];
    }
}

- (void)populateCongressmenFromLocation:(CLLocation*)location {
    [[RepManager sharedInstance]createCongressmenFromLocation:location WithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } onError:^(NSError *error) {
        [error localizedDescription];
    }];
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    return 100;
}

- (void)presentCustomAlert {
    UIViewController *infoViewController = [[UIStoryboard storyboardWithName:@"Info" bundle:nil] instantiateViewControllerWithIdentifier:@"customAlertViewController"];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:infoViewController];
    popupController.cornerRadius = 10;
    if (NSClassFromString(@"UIBlurEffect")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:17] } forState:UIControlStateNormal];
        
    [popupController presentInViewController:self];
}
@end