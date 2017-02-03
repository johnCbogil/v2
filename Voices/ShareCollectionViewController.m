//
//  ShareCollectionViewController.m
//  Voices
//
//  Created by Daniel Nomura on 2/2/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ShareCollectionViewController.h"
#import "ShareCollectionViewCell.h"
#import <STPopup.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>



@interface ShareCollectionViewController () <MFMessageComposeViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, ShareCollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray <NSNumber *> *installedApps;

@end

@implementation ShareCollectionViewController

static NSString * const reuseIdentifier = @"ShareCell";
static CGFloat const cellHeight = 80;

#pragma mark - Lifecycle VC methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ShareCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.title = @"Share";
    self.contentSizeInPopup = CGSizeMake(self.view.frame.size.width * .9, cellHeight + 16);
    [self setAvailableApps];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Setup methods
- (void)setAvailableApps {
    self.installedApps = [NSMutableArray arrayWithObject:@(SMS)];
    // Add @"fb-messenger://" for fb messenger
    NSArray *appURLPaths = @[@"fb://", @"twitter://"];
    for (NSString *path in appURLPaths) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:path]]) {
            InstalledApp app = [self appForURLPath:path];
            [self.installedApps addObject:@(app)];
        }
    }
}

#pragma mark - Delegate methods
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.installedApps.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ShareCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    InstalledApp app = self.installedApps[indexPath.row].intValue;
    cell.app = app;
    cell.delegate = self;
    UIImage * iconImage = [self iconForApp: app];
    [cell.appIconButton setImage:iconImage forState:UIControlStateNormal];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
//- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self presentActionViewControllerForApp: self.installedApps[indexPath.row].intValue];
//}

#pragma mark <MFMessageComposeViewControllerDelegate>
- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark <ShareCollectionViewCellDelegate>
- (void) shareCollectionViewCell:(ShareCollectionViewCell *)sender didPressApp:(InstalledApp)app {
    switch (app) {
        case Twitter:
        case Facebook:
        {
            NSString *serviceType = [self serviceTypeForApp:app];
            if (serviceType) {
                SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
                if (composeViewController) {
                    composeViewController.completionHandler = nil;
                    BOOL willSetText = [composeViewController setInitialText:self.shareString];
                    if (!willSetText) {
                        willSetText = [composeViewController setInitialText:self.shortenedShareString];
                        if (!willSetText) { NSLog(@"Will not set initial text: %@", self.shortenedShareString); }
                    }
                    [self presentViewController:composeViewController animated:YES completion:^{
                        [sender hideWaitingView];
                    }];
                } else {
                    [sender hideWaitingView];
                    [self showShareErrorForApp:app];
                }
            }
            break;
        }
        case FBMessenger:
            break;
        case SMS:
        {
            MFMessageComposeViewController *composeViewController = [[MFMessageComposeViewController alloc] init];
            if (composeViewController) {
                composeViewController.messageComposeDelegate = self;
                composeViewController.body = self.shareString;
                [self presentViewController:composeViewController animated:YES completion:^{
                    [sender hideWaitingView];
                }];
            } else {
                [sender hideWaitingView];
            }
            break;
        }
    }
}

- (void)showShareErrorForApp:(InstalledApp) app {
    NSString *appName = [self nameForApp:app];
    if (!appName) { return; }
    NSString *title = [NSString stringWithFormat:@"Unable to open %@", appName];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:confirm];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - InstalledApp enum methods
- (NSString*)urlPathForApp:(InstalledApp) app {
    switch (app) {
        case Facebook:
            return @"fb://";
        case Twitter:
            return @"twitter://";
        case SMS:
            return @"";
        case FBMessenger:
            return @"fb-messenger://";
    }
}

- (InstalledApp)appForURLPath:(NSString *) path {
    if ([path isEqualToString:@"fb-messenger://"]) {
        return FBMessenger;
    } else if ([path isEqualToString:@"fb://"]) {
        return Facebook;
    } else if([path isEqualToString:@"twitter://"]) {
        return Twitter;
    } else {
        return 0;
    }
}

- (UIImage*)iconForApp:(InstalledApp) app{
    switch (app) {
        case Facebook:
            return [UIImage imageNamed:@"fb-icon"];
            break;
        case FBMessenger:
            return [UIImage imageNamed:@""];
            break;
        case Twitter:
            return [UIImage imageNamed:@"twitter-icon"];
            break;
        case SMS:
            return [UIImage imageNamed:@"sms-icon"];
            break;
    }
}

- (NSString *)serviceTypeForApp: (InstalledApp) app {
    switch (app) {
        case Facebook:
            return SLServiceTypeFacebook;
        case Twitter:
            return SLServiceTypeTwitter;
        default:
            return nil;
    }
}

- (NSString *)nameForApp: (InstalledApp) app {
    switch (app) {
        case Facebook:
            return @"Facebook";
        case Twitter:
            return @"Twitter";
        case FBMessenger:
            return @"Facebook Messenger";
        case SMS:
            return @"Messages";
        default:
            return nil;
    }
}
@end
