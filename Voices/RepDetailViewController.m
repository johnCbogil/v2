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
#import "RepDetailTableViewCell.h"

int contactTypeCount = 4;

@interface RepDetailViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *repImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSArray *contactTypeLabels;
@property (strong, nonatomic) NSArray *contactTypeImageNames;
@property (strong, nonatomic) NSArray *contactInfoLabels;

@end

// TODO: ADD THIRD LINE TO BIO THAT INCLUDES PARTY COLOR AND STATE/DISTRICT
// TODO: STYLE CONTACT LABELS
// TODO: HOOK UP WEBSITE AND FACEBOOK INFO
// TODO: MOVE BIO INTO TABLEVIEWCELL
// TODO: MOVE IMAGEVIEW LEFT
// TODO: CHANGE BACKGROUND GRAY COLOR
// TODO: STYLE BIO LABELS
// TODO: IMPLEMENT DIDSELECTROW

@implementation RepDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contactTypeImageNames = @[@"Phone Filled", @"Twitter Filled", @"InfoButton", @"Facebook"];
    self.contactTypeLabels = @[@"Phone", @"Twitter", @"Website", @"Facebook"];
    self.contactInfoLabels = @[self.representative.phoneRaw, self.representative.twitter, self.representative.website, self.representative.facebook];
    [self configureNavigationController];
    [self configureLabels];
    [self configureTableView];
    [self configureImage];
}

- (void)configureLabels {
    
    self.nameLabel.font = [UIFont voicesMediumFontWithSize:24];
    self.nameLabel.numberOfLines = 0;
    [self.nameLabel sizeToFit];
    self.nameLabel.minimumScaleFactor = 0.5;
    self.nameLabel.text = self.representative.fullName;
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@, %@", self.representative.title, self.representative.party];
    self.titleLabel.font = [UIFont voicesMediumFontWithSize:18];
    self.titleLabel.numberOfLines = 0;
}

- (void)configureNavigationController {
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    self.title = @"Rep Details";
}

- (void)configureTableView {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 100;
    self.tableView.allowsSelection = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"RepDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"RepDetailTableViewCell"];
    self.tableView.separatorColor = [UIColor clearColor];
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

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return contactTypeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RepDetailTableViewCell *cell = (RepDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RepDetailTableViewCell" forIndexPath:indexPath];
    cell.contactInfoLabel.text = self.contactInfoLabels[indexPath.row];
    cell.contactTypeLabel.text = self.contactTypeLabels[indexPath.row];
    cell.contactTypeImageView.image = [UIImage imageNamed:self.contactTypeImageNames[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - OpenSecrets Code - This will come back one day.

//- (void)presentOpenSecretsWebViewController {
//
//    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
//    WebViewController *webViewController = (WebViewController *)[repsSB instantiateViewControllerWithIdentifier:@"WebViewController"];
//    webViewController.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.opensecrets.org/politicians/summary.php?cycle=2016&type=I&cid=%@", self.representative.crpID]];
//    webViewController.title = @"OpenSecrets";
//    webViewController.navigationItem.backBarButtonItem = nil;
//    [self.navigationController pushViewController:webViewController animated:YES];
//}

//- (void)fetchTopContributors {
//
//    [self toggleActivityIndicatorOn];
//
//    [[RepsNetworkManager sharedInstance]getTopContributorsForRep:self.representative.crpID withCompletion:^(NSData *results) {
//
//        NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:results options:kNilOptions error:nil];
//        self.topContributorsArray = resultsDict[@"response"][@"contributors"][@"contributor"];
//        [self.tableView reloadData];
//        [self toggleActivityIndicatorOff];
//
//    } onError:^(NSError *error) {
//        NSLog(@"%@", [error localizedDescription]);
//    }];
//}

//- (void)fetchTopIndustries {
//
//    [self toggleActivityIndicatorOn];
//
//    [[RepsNetworkManager sharedInstance]getTopIndustriesForRep:self.representative.crpID withCompletion:^(NSData *results) {
//
//        NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:results options:kNilOptions error:nil];
//        self.topIndustriesArray = resultsDict[@"response"][@"industries"][@"industry"];
//        NSLog(@"%@", resultsDict);
//        [self.tableView reloadData];
//        [self toggleActivityIndicatorOff];
//
//    } onError:^(NSError *error) {
//        NSLog(@"%@", [error localizedDescription]);
//    }];
//}

//- (NSString *)formatMoney:(NSString *)number {
//
//    // CONVERT STRING TO NUMBER
//    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//    f.numberStyle = NSNumberFormatterDecimalStyle;
//    NSNumber *myNumber = [f numberFromString:number];
//
//    // CONVERT NUMBER TO STRING
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//    return [formatter stringFromNumber:myNumber];
//}

@end
