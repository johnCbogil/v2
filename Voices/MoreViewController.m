//
//  MoreViewController.m
//  Voices
//
//  Created by Andy Wu on 3/15/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()

@property (weak, nonatomic) IBOutlet UITableView *moreTableView;

@end

@implementation MoreViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.moreTableView.delegate = self;
    self.moreTableView.dataSource = self;
    
//    self.dataArray = [[NSArray alloc] initWithObjects:@"Feedback", @"Share app", @"Rate in app store", @"About", @"FAQ", @"Voter registration", @"Enable location", @"Enable push notification", nil];
    self.choiceArray = [[NSArray alloc] initWithObjects:@"About", @"Rate App", @"Issue Survey", nil];
    
    self.subtitleArray = [[NSArray alloc] initWithObjects:@"Ask us anything!", @"A higher rating means more people can use the app to support your causes", @"What issues are important to you?", nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    cell.detailTextLabel.text = [self.subtitleArray objectAtIndex:indexPath.row];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AboutViewController *aboutVC = [[AboutViewController alloc] init];
    IssueSurveyViewController *issueSurveyVC = [[IssueSurveyViewController alloc] init];
    NSString *iTunesAppLink = @"itms://itunes.apple.com/us/app/congress-voices/id965692648?mt=8";
    switch ([indexPath row]) {
        case 0:
            [aboutVC.navigationItem setTitle:@"About"];
            [self.navigationController pushViewController:aboutVC animated:YES];
            break;
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesAppLink]];
            break;
        case 2:
            issueSurveyVC.urlString = @"https://www.google.com";
            [issueSurveyVC.navigationItem setTitle:@"Issue Survey"];
            [self.navigationController pushViewController:issueSurveyVC animated:YES];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
