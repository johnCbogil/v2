//
//  MoreViewController.m
//  Voices
//
//  Created by Andy Wu on 3/15/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "MoreViewController.h"
#import <StoreKit/StoreKit.h>
#import "STPopupController.h"
#import <Instabug/Instabug.h>

@interface MoreViewController ()

@property (weak, nonatomic) IBOutlet UITableView *moreTableView;

@end

@implementation MoreViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    
    self.choiceArray = [[NSArray alloc] initWithObjects:@"Pro Tips", @"Rate App", @"Issue Survey", @"Send Feedback", nil];
    self.subtitleArray = [[NSArray alloc] initWithObjects:@"Make your actions more effective.", @"A higher rating means more people can find the app to support your causes.", @"What issues are important to you?", @"Your ideas make Voices better.", nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)rateApp {
    
    if([SKStoreReviewController class]){
        [SKStoreReviewController requestReview] ;
    }
    else {
        NSString *iTunesAppLink = @"itms://itunes.apple.com/us/app/congress-voices/id965692648?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesAppLink]];
    }
}

#pragma mark - TableView methods

- (void)configureTableView {
    
    self.moreTableView.delegate = self;
    self.moreTableView.dataSource = self;
    self.moreTableView.rowHeight = 80;
    self.moreTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.choiceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self.choiceArray objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [self.subtitleArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont voicesBoldFontWithSize:20];
    cell.detailTextLabel.font = [UIFont voicesFontWithSize:14];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.moreTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IssueSurveyViewController *issueSurveyVC = [[IssueSurveyViewController alloc] init];
    switch ([indexPath row]) {
        case 0:
            [self presentProTipsViewController];
            break;
        case 1:
            [self rateApp];
            break;
        case 2:
            issueSurveyVC.urlString = @"https://goo.gl/forms/m9Ux4UJ5MAJmuZyz1";
            [issueSurveyVC.navigationItem setTitle:@"Issue Survey"];
            [self.navigationController pushViewController:issueSurveyVC animated:YES];
            break;
        case 3:
            [Instabug invoke];
        default:
            break;
    }
}

- (void)presentProTipsViewController {
    
    UIViewController *infoViewController = (UIViewController *)[[[NSBundle mainBundle] loadNibNamed:@"NewInfo" owner:self options:nil] objectAtIndex:0];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:infoViewController];
    popupController.containerView.layer.cornerRadius = 10;
    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor]; // This is the only OK "orangeColor", for now
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:23], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[STPopupNavigationBar class]]] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:19] } forState:UIControlStateNormal];
    [popupController presentInViewController:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
