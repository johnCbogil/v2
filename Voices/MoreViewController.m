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
#import "SearchViewController.h"
#import "WebViewController.h"
#import "MoreTableViewCell.h"

@interface MoreViewController ()

@property (weak, nonatomic) IBOutlet UITableView *moreTableView;
@property (strong, nonatomic) NSArray *emojiArray;

@end

@implementation MoreViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (!homeAddress.length) {
        homeAddress = @"Not added yet.";
    }
    self.emojiArray = @[@"💪",@"🙋🏽",@"⭐",@"🗣️",@"🏡"];
    self.choiceArray = [[NSArray alloc] initWithObjects: @"Pro Tips", @"Issue Survey", @"Rate App", @"Send Feedback",@"Add Home Address", nil];
    self.subtitleArray = [[NSArray alloc] initWithObjects: @"Make your actions more effective.", @"What issues are important to you?", @"A higher rating means more people can find the app to support your cause.", @"What could Voices do better to support your cause?", homeAddress, nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadAddressCell) name:@"endFetchingReps" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadAddressCell) name:@"endFetchingStreetAddress" object:nil];
    
    [self.moreTableView registerNib:[UINib nibWithNibName:@"MoreTableViewCell" bundle:nil]forCellReuseIdentifier:@"MoreTableViewCell"];
}

- (void)reloadAddressCell {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0] ;
    [self.moreTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
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
    self.moreTableView.estimatedRowHeight = 100.0;
    self.moreTableView.rowHeight = UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.choiceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreTableViewCell"];
    cell.titleLabel.text = self.choiceArray[indexPath.row];
    cell.subtitleLabel.text = self.subtitleArray[indexPath.row];
    cell.emojiLabel.text = self.emojiArray[indexPath.row];
    
        if (indexPath.row == self.choiceArray.count) {
            NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
            if (!homeAddress.length) {
                homeAddress = @"Not added yet.";
            }
            cell.subtitleLabel.text = homeAddress;
        }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.moreTableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    WebViewController *webVC = (WebViewController *)[repsSB instantiateViewControllerWithIdentifier:@"WebViewController"];
    
    switch ([indexPath row]) {
        case 0:
            
            [self presentProTipsViewController];
            break;
        case 1:
            
            webVC.url = [NSURL URLWithString:@"https://goo.gl/forms/m9Ux4UJ5MAJmuZyz1"];
            [webVC.navigationItem setTitle:@"Issue Survey"];
            [self.navigationController pushViewController:webVC animated:YES];
            break;
        case 2:
            
            [self rateApp];
            break;
        case 3:
            
            
            webVC.url = [NSURL URLWithString:@"https://docs.google.com/a/tryvoices.com/forms/d/e/1FAIpQLSdwgwjbYWtvIDqefMZtDttTak-5-P92I1r6HhanEXql_hmjxA/viewform"];
            [webVC.navigationItem setTitle:@"Feedback Form"];
            [self.navigationController pushViewController:webVC animated:YES];
            break;
        case 4:
    
            [self presentSearchViewController];
            break;

        default:
            break;
    }
}

- (void)presentSearchViewController {
    
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    SearchViewController *searchViewController = (SearchViewController *)[repsSB instantiateViewControllerWithIdentifier:@"SearchViewController"];
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (homeAddress.length > 0) {
        searchViewController.title = @"Edit Home Address";
    }
    else {
        searchViewController.title = @"Add Home Address";
    }
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    [self.navigationController pushViewController:searchViewController animated:YES];
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

@end
