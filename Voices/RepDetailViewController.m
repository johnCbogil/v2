//
//  RepDetailViewController.m
//  Voices
//
//  Created by Ben Rosenfeld on 8/25/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepDetailViewController.h"
#import "ReportingManager.h"
#import "ScriptManager.h"
#import "RepsNetworkManager.h"

@interface RepDetailViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *repImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *partyStateLabel;
@property (weak, nonatomic) IBOutlet UIView *actionContainerView;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UILabel *topInfluencersLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *topContributorsArray;
@property (strong, nonatomic) NSArray *topIndustriesArray;

@end

// TODO: DIANNE FEINSTEIN REP NAME IS TOO LONG

@implementation RepDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self configureNavigationController];
    [self configureLabels];
    [self configureTableView];
    [self configureActionButtons];
    [self configureImage];
    [self fetchTopContributors];
}

- (void)fetchTopContributors {
    
    [[RepsNetworkManager sharedInstance]getTopContributorsForRep:self.representative.crpID withCompletion:^(NSData *results) {
        
        NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:results options:kNilOptions error:nil];
        self.topContributorsArray = resultsDict[@"response"][@"contributors"][@"contributor"];
        [self.tableView reloadData];
        
    } onError:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
        
    }];
}

- (void)fetchTopIndustries {
    
    [[RepsNetworkManager sharedInstance]getTopIndustriesForRep:self.representative.crpID withCompletion:^(NSData *results) {
        
        NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:results options:kNilOptions error:nil];
        self.topIndustriesArray = resultsDict[@"response"][@"industries"][@"industry"];
        NSLog(@"%@", resultsDict);
        [self.tableView reloadData];
        
        
    } onError:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (void)configureActionButtons {
    
    self.callButton.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.twitterButton.tintColor = [UIColor voicesOrange];
}

- (void)configureSegmentedControl {
    
    [self.segmentedControl setTitle:@"Industry" forSegmentAtIndex:1];
    [self.segmentedControl setTitle:@"Contributor" forSegmentAtIndex:0];
    self.segmentedControl.tintColor = [UIColor voicesOrange];
    [self.segmentedControl setSelectedSegmentIndex:0];
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.layer.cornerRadius = kButtonCornerRadius;
    [self.segmentedControl setTitleTextAttributes:@{NSFontAttributeName : [UIFont voicesFontWithSize:19]} forState:UIControlStateNormal];
}

- (void)configureLabels {
    
    self.titleLabel.text = self.representative.title;
    self.nameLabel.font = [UIFont voicesFontWithSize:34];
    self.titleLabel.font = [UIFont voicesFontWithSize:34];
    self.nameLabel.text = self.representative.fullName;
    self.partyStateLabel.text = [NSString stringWithFormat:@"%@-%@", self.representative.stateCode, self.representative.party];
    self.partyStateLabel.font = [UIFont voicesFontWithSize:26];
    self.topInfluencersLabel.font = [UIFont voicesFontWithSize:26];
}

- (void)configureNavigationController {
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    self.title = @"More Info";
}

- (void)configureTableView {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)configureImage {
    UIImage *placeholderImage;
    if(self.representative.gender){
        if ([self.representative.gender isEqualToString:@"M"]) {
            placeholderImage = [UIImage imageNamed:kRepDefaultImageMale];
        }
        else {
            placeholderImage = [UIImage imageNamed:kRepDefaultImageFemale];
        }
    }
    else {
        if ( drand48() < 0.5 ){
            placeholderImage  = [UIImage imageNamed:kRepDefaultImageMale];
        } else {
            placeholderImage  = [UIImage imageNamed:kRepDefaultImageFemale];
        }
    }
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.representative.photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.repImageView setImageWithURLRequest:imageRequest placeholderImage:placeholderImage success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        
        [UIView animateWithDuration:.25 animations:^{
            self.repImageView.image = image;
        }];
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        
    }];
    
    self.repImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.repImageView.layer.cornerRadius = 5;
    self.repImageView.clipsToBounds = YES;
}

- (IBAction)segmentedControlDidChange:(id)sender {
    
    if (self.segmentedControl.selectedSegmentIndex == 0 && !self.topContributorsArray.count) {
        
        [self fetchTopContributors];
        
    }
    else if (!self.topIndustriesArray.count) {
        
        [self fetchTopIndustries];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        return self.topIndustriesArray.count;
    }
    else {
        return self.topContributorsArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@",self.topIndustriesArray[indexPath.row][@"@attributes"][@"industry_name"], self.topIndustriesArray[indexPath.row][@"@attributes"][@"total"]];
        
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", self.topContributorsArray[indexPath.row][@"@attributes"][@"org_name"], self.topContributorsArray[indexPath.row][@"@attributes"][@"total"] ];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
