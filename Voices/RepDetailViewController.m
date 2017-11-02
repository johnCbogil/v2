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
#import "WebViewController.h"
#import "ActionView.h"

@interface RepDetailViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *repImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *actionContainerView;
@property (weak, nonatomic) IBOutlet UILabel *topInfluencersLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *topContributorsArray;
@property (strong, nonatomic) NSArray *topIndustriesArray;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet ActionView *actionView;

@end

@implementation RepDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationController];
    [self configureLabels];
    [self configureTableView];
    [self configureImage];
    [self configureActivityIndicator];
    [self configureSegmentedControl];
    [self configureTopInfluencersButton];
    [self fetchTopIndustries];
    [self.actionView configureWithRepresentative:self.representative];
}

- (void)configureTopInfluencersButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setImage:[UIImage imageNamed:@"infoButton"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(presentTopInfluencersInfoAlert) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc] init];
    [barButton setCustomView:button];
    self.navigationItem.rightBarButtonItem=barButton;
}

- (void)presentTopInfluencersInfoAlert {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Top Influencers" message:@"Information is provided by OpenSecrets.org and represents the latest election cycle." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Visit OpenSecrets" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
     
        [self presentOpenSecretsWebViewController];
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)presentOpenSecretsWebViewController {
    
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    WebViewController *webViewController = (WebViewController *)[repsSB instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.opensecrets.org/politicians/summary.php?cycle=2016&type=I&cid=%@", self.representative.crpID]];
    webViewController.title = @"OpenSecrets";
    webViewController.navigationItem.backBarButtonItem = nil;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)configureActivityIndicator {
    
    self.indicatorView = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.color = [UIColor grayColor];
    self.indicatorView.frame = CGRectMake(0, 0, 30.0f, 30.0f);
    self.indicatorView.hidden = false;
    self.indicatorView.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:self.indicatorView];
    
    NSLayoutConstraint *horizontalConstraint = [self.indicatorView.centerXAnchor constraintEqualToAnchor: self.view.centerXAnchor];
    NSLayoutConstraint *verticalConstraint = [self.indicatorView.centerYAnchor constraintEqualToAnchor:self.view.bottomAnchor constant: -self.view.frame.size.height/6];
    NSArray *constraints = [[NSArray alloc]initWithObjects:horizontalConstraint, verticalConstraint, nil];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)toggleActivityIndicatorOn {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView startAnimating];
    });
}

- (void)toggleActivityIndicatorOff {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView stopAnimating];
    });
}

- (void)fetchTopContributors {
    
    [self toggleActivityIndicatorOn];
    
    [[RepsNetworkManager sharedInstance]getTopContributorsForRep:self.representative.crpID withCompletion:^(NSData *results) {
        
        NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:results options:kNilOptions error:nil];
        self.topContributorsArray = resultsDict[@"response"][@"contributors"][@"contributor"];
        [self.tableView reloadData];
        [self toggleActivityIndicatorOff];
        
    } onError:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (void)fetchTopIndustries {
    
    [self toggleActivityIndicatorOn];
    
    [[RepsNetworkManager sharedInstance]getTopIndustriesForRep:self.representative.crpID withCompletion:^(NSData *results) {
        
        NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:results options:kNilOptions error:nil];
        self.topIndustriesArray = resultsDict[@"response"][@"industries"][@"industry"];
        NSLog(@"%@", resultsDict);
        [self.tableView reloadData];
        [self toggleActivityIndicatorOff];
        
    } onError:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (void)configureSegmentedControl {
    
    [self.segmentedControl setTitle:@"Industry" forSegmentAtIndex:0];
    [self.segmentedControl setTitle:@"Contributor" forSegmentAtIndex:1];
    self.segmentedControl.tintColor = [UIColor voicesOrange];
    [self.segmentedControl setSelectedSegmentIndex:0];
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.layer.cornerRadius = kButtonCornerRadius;
    [self.segmentedControl setTitleTextAttributes:@{NSFontAttributeName : [UIFont voicesFontWithSize:19]} forState:UIControlStateNormal];
}

- (void)configureLabels {
    
   
    self.nameLabel.font = [UIFont voicesMediumFontWithSize:30];
    self.nameLabel.numberOfLines = 0;
    [self.nameLabel sizeToFit];
    self.nameLabel.minimumScaleFactor = 0.5;
    self.nameLabel.text = self.representative.fullName;
    self.topInfluencersLabel.font = [UIFont voicesMediumFontWithSize:22];
}

- (void)configureNavigationController {
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    self.title = @"Details";
}

- (void)configureTableView {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    self.tableView.allowsSelection = NO;
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
    
    if (self.segmentedControl.selectedSegmentIndex == 0 && !self.topIndustriesArray.count) {
        [self fetchTopIndustries];
        
    }
    else if (!self.topContributorsArray.count) {
        
        [self fetchTopContributors];


    }
    [self.tableView reloadData];
}

- (NSString *)formatMoney:(NSString *)number {
    
    // CONVERT STRING TO NUMBER
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString:number];
    
    // CONVERT NUMBER TO STRING
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    return [formatter stringFromNumber:myNumber];
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        return self.topContributorsArray.count;
    }
    else {
        return self.topIndustriesArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        
        NSString *total = [self formatMoney:self.topContributorsArray[indexPath.row][@"@attributes"][@"total"]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",self.topContributorsArray[indexPath.row][@"@attributes"][@"org_name"],total];
        
    }
    else {
        
        NSString *total = [self formatMoney:self.topIndustriesArray[indexPath.row][@"@attributes"][@"total"]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", self.topIndustriesArray[indexPath.row][@"@attributes"][@"industry_name"], total];
    }
    cell.textLabel.font = [UIFont voicesFontWithSize:19];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
