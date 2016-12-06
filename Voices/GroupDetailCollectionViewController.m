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

@interface GroupDetailCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *policyPositionsRef;

@property (strong, nonatomic) NSMutableArray *listOfPolicyPositions;


@end

@implementation GroupDetailCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINib *nib0 = [UINib nibWithNibName:@"GroupLogoCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib0 forCellWithReuseIdentifier:@"cell0"];
    
    UINib *nib1 = [UINib nibWithNibName:@"GroupDescriptionCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib1 forCellWithReuseIdentifier:@"cell1"];
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    self.policyPositionsRef = [[self.groupsRef child:self.group.key]child:@"policyPositions"];

    [self configureCollectionView];
//    [self fetchPolicyPositions];
    self.title = self.group.name;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    
}


- (void)configureCollectionView {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(375, 334)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    [self.collectionView setCollectionViewLayout:flowLayout];

//    self.collectionView.delegate = self;
//    self.collectionView.dataSource = self;
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
//    
//    UINib *nib0 = [UINib nibWithNibName:@"GroupLogoCollectionViewCell" bundle:nil];
//    
//    [self.collectionView registerNib:nib0 forCellWithReuseIdentifier:@"cell0"];
//    
//    UINib *nib1 = [UINib nibWithNibName:@"GroupDescriptionCollectionViewCell" bundle:nil];
//    [self.collectionView registerNib:nib1 forCellWithReuseIdentifier:@"cell1"];
//    [self.collectionView registerClass:[GroupLogoCollectionViewCell class]forCellWithReuseIdentifier:@"cell0"];
//    [self.collectionView registerClass: [GroupDescriptionCollectionViewCell class] forCellWithReuseIdentifier:@"cell1"];
    
    
}
// WILL NEED FOR POLICY SECTION

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
    
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identifier;
    // your cell condition here
    
   
    
    if(indexPath.item == 0) {
        identifier = @"cell0";
        GroupLogoCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        if(cell!=nil){// cell nil condition
         }
        // cell coding here
        return cell;
    }else{
        // second custom cell code here
        identifier = @"cell1";
        GroupDescriptionCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        // cell coding here
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"**** didSelectRowAtIndexpath called *****");
    
 }

// OLD TABLE VIEW METHODS - WILL NEED FOR POLICY SECTION

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
