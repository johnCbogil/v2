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
typedef enum {
    Facebook = 1,
    Twitter,
    SMS,
    FBMessenger
} InstalledApp;
@interface ShareCollectionViewController () <MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) NSMutableArray <NSNumber *> *installedApps;
@end

@implementation ShareCollectionViewController

static NSString * const reuseIdentifier = @"ShareCell";

#pragma mark - Lifecycle VC methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[ShareCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.title = @"Pro Tips";
    self.contentSizeInPopup = CGSizeMake(self.view.frame.size.width * .9, self.view.frame.size.height * .65);

    [self setAvailableApps];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Setup methods
- (void)setAvailableApps {
    self.installedApps = [NSMutableArray arrayWithObject:@(SMS)];
    NSArray *appURLPaths = @[@"fb://", @"twitter://", @"fb-messenger://"];
    for (NSString *path in appURLPaths) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:path]]) {
            InstalledApp app = [self appForURLPath:path];
            [self.installedApps addObject:@(app)];
        }
    }
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

- (UIImage*)imageForApp:(InstalledApp) app{
    switch (app) {
        case Facebook:
            return [UIImage new];
            break;
        case FBMessenger:
            return [UIImage new];
            break;
        case Twitter:
            return [UIImage new];
            break;
        case SMS:
            return [UIImage new];
            break;
    }
}

- (NSString *)serviceTypeForApp: (InstalledApp) app {
    switch (app) {
        case Facebook:
            return SLServiceTypeFacebook;
            break;
        case Twitter:
            return SLServiceTypeTwitter;
            break;
        default:
            return nil;
    }
}


- (void)presentActionViewControllerForApp: (InstalledApp) app {
    switch (app) {
        case Twitter:
        case Facebook:
        {
            NSString *serviceType = [self serviceTypeForApp:app];
            if (serviceType) {
                SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
                [composeViewController setInitialText:self.shareString];
                [self.navigationController presentViewController:composeViewController animated:YES completion:nil];
            }
            break;
        }
        case FBMessenger:
            break;
        case SMS:
        {
            MFMessageComposeViewController *composeViewController = [[MFMessageComposeViewController alloc] init];
            composeViewController.delegate = self;
            composeViewController.body = self.shareString;
            [self.navigationController presentViewController:composeViewController animated:YES completion:nil];
            break;
        }
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.installedApps.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ShareCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    UIImage * iconImage = [self imageForApp:self.installedApps[indexPath.row].intValue];
    cell.appIcon = [[UIImageView alloc] initWithImage:iconImage];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self presentActionViewControllerForApp: self.installedApps[indexPath.row].intValue];
}

#pragma mark <MFMessageComposeViewControllerDelegate>
- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
}

@end
