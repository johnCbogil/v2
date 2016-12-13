//
//  GroupDetailCollectionViewController.m
//  Voices
//
//  Created by perrin cloutier on 12/5/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "GroupDetailCollectionViewController.h"
#import "PolicyDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "PolicyPosition.h"
#import "CurrentUser.h"
#import "GroupLogoCollectionViewCell.h"
#import "GroupDescriptionCollectionViewCell.h"

@import Firebase;

@interface GroupDetailCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *followStatus;
@property (strong, nonatomic) UIImageView *groupImageView;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *policyPositionsRef;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic) id delegate;


@property (strong, nonatomic) NSMutableArray *listOfPolicyPositions;


@end

@implementation GroupDetailCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    self.policyPositionsRef = [[self.groupsRef child:self.group.key]child:@"policyPositions"];
    [self configureCollectionView];
    [self configurePageControl];
//    [self fetchPolicyPositions];
    self.title = self.group.name;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
}


- (void)configureCollectionView {
    
    UINib *nib0 = [UINib nibWithNibName:@"GroupLogoCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib0 forCellWithReuseIdentifier:@"cell0"];
    
    UINib *nib1 = [UINib nibWithNibName:@"GroupDescriptionCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib1 forCellWithReuseIdentifier:@"cell1"];
   
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(375, 270)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        
        self.automaticallyAdjustsScrollViewInsets = NO;
     }
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}


#pragma mark - PageControl 


- (void)configurePageControl {
    
    // Add a target that will be invoked when the page control is changed by tapping on it
    [self.pageControl
     addTarget:self
     action:@selector(pageControlChanged:)
     forControlEvents:UIControlEventValueChanged
     ];
    
    // Set the number of pages to the number of pages in the paged interface and let the height flex so that it sits nicely in its frame
    self.pageControl.numberOfPages = 2;
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}


- (void)pageControlChanged:(id)sender
{
    UIPageControl *pageControl = sender;
    CGFloat pageWidth = self.collectionView.frame.size.width;
    CGPoint scrollTo = CGPointMake(pageWidth * pageControl.currentPage, 0);
    [self.collectionView setContentOffset:scrollTo animated:YES];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    self.pageControl.currentPage = self.collectionView.contentOffset.x / pageWidth;
}


#pragma mark - Follow Status


- (void)observeFollowStatus:(GroupLogoCollectionViewCell *)cell {
    
         [[[[self.usersRef child:self.currentUserID] child:@"groups"]child:self.group.key] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    
            if (snapshot.value != [NSNull null]) {
    
                if ([cell.followGroupButton.titleLabel.text isEqualToString:@"Following ▾"]) {
                    [cell.followGroupButton setTitle:@"Follow This Group" forState:UIControlStateNormal];
                 }else{
                    [cell.followGroupButton setTitle: @"Following ▾" forState:UIControlStateNormal] ;
                }
            }
        }];
}


#pragma mark - FollowGroupDelegate/Firebase methods


- (void)followGroupButtonDidPress:(GroupLogoCollectionViewCell *)cell {
    
    // TODO: ASK FOR NOTI PERMISSION FROM STPOPUP BEFORE ASKING FOR PERMISSION
    UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
    NSString *groupKey = self.group.key;
    
    [[CurrentUser sharedInstance]followGroup:groupKey WithCompletion:^(BOOL isUserFollowingGroup) {
        
        if (!isUserFollowingGroup) {
            
            NSLog(@"User subscribed to %@", groupKey);
        }
        else {
            
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                        message:@"Would you like to stop supporting this group?"
                                        preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *button0 = [UIAlertAction
                                      actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleCancel
                                      handler:^(UIAlertAction * action)
                                      {}];
            
            UIAlertAction *button1 = [UIAlertAction
                                      actionWithTitle:@"Unfollow"
                                      style:UIAlertActionStyleDestructive
                                      handler:^(UIAlertAction * action) {
                                          
                                          // Remove group
                                          [[CurrentUser sharedInstance]removeGroup:self.group];
                                          
                                          // read the value once to see if group key exists
                                          [[[[self.usersRef child:self.currentUserID] child:@"groups"]child:self.group.key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                              if (snapshot.value == [NSNull null]) {
                                                  
                                                
                                                  [cell.followGroupButton setTitle:@"Follow This Group" forState:UIControlStateNormal];
                                                  
                                              }
                                          } withCancelBlock:^(NSError * _Nonnull error) {
                                              NSLog(@"%@", error.localizedDescription);
                                          }];
                                      }];
            
            [alert addAction:button0];
            [alert addAction:button1];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } onError:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}


#pragma mark - Policy Positions


//- (void)fetchPolicyPositions {
//    
//    __weak GroupDetailViewController *weakSelf = self;
//    [self.policyPositionsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        NSDictionary *policyPositionsDict = snapshot.value;
//        NSMutableArray *policyPositionsArray = [NSMutableArray array];
//        [policyPositionsDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//            PolicyPosition *policyPosition = [[PolicyPosition alloc]initWithKey:key policyPosition:obj];
//            [policyPositionsArray addObject:policyPosition];
//        }];
//        weakSelf.listOfPolicyPositions = [NSMutableArray arrayWithArray:policyPositionsArray];
//        [weakSelf.tableView reloadData];
//    } withCancelBlock:^(NSError * _Nonnull error) {
//        NSLog(@"%@", error.localizedDescription);
//    }];
//}


#pragma mark - UICollectionView methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier;
    // your cell condition here
    
    if(indexPath.item == 0) {
        
        // first custom cell
        identifier = @"cell0";
        GroupLogoCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
      
        // obtain the following status
        [self observeFollowStatus:cell];
        
       // set the delegate pattern between the cell and the CollectionViewController
        cell.followGroupDelegate = self;
        [cell initWithGroup:self.group];
 
        return cell;
    }else{
        // second custom cell code
        identifier = @"cell1";
        GroupDescriptionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
         [cell initWithGroup:self.group];
        
        return cell;
    }
}


// WILL BE USEFUL FOR LATER IN POLICY SECTION

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.listOfPolicyPositions.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    cell.textLabel.text = [self.listOfPolicyPositions[indexPath.row]key];
//    cell.textLabel.font = [UIFont voicesFontWithSize:19];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    // Allows centering of the nav bar title by making an empty back button
//    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    [self.navigationItem setBackBarButtonItem:backButtonItem];
//    
//    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
//    PolicyDetailViewController *policyDetailViewController = (PolicyDetailViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier: @"PolicyDetailViewController"];
//    policyDetailViewController.policyPosition = self.listOfPolicyPositions[indexPath.row];
//    [self.navigationController pushViewController:policyDetailViewController animated:YES];
//    
//}

@end
