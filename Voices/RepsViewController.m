//
//  RepsViewController.m
//  Voices
//
//  Created by Bogil, John on 11/11/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepsViewController.h"
#import "RepsManager.h"
#import "RootViewController.h"
#import "AddAddressCollectionViewCell.h"

@interface RepsViewController()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *pageIndicatorContainer;
@property (weak, nonatomic) IBOutlet UIButton *federalButton;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak, nonatomic) IBOutlet UIButton *localButton;
@property (strong, nonatomic) NSDictionary *buttonDictionary;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end


@implementation RepsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureCollectionView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadCollectionView) name:@"reloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage:) name:@"jumpPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPageIndicator:) name:@"actionPageJump" object:nil];

    [self.collectionView.collectionViewLayout invalidateLayout]; // TODO: CAN I MOVE THIS INTO CONFIGURECOLLECTIONVIEW
    
    self.buttonDictionary = @{@0 : self.federalButton, @1 : self.stateButton , @2 :self.localButton};
    
//    self.infoButton.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:1];
    self.federalButton.tintColor = [UIColor voicesBlue];
    self.stateButton.tintColor = [UIColor voicesLightGray];
    self.localButton.tintColor = [UIColor voicesLightGray];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]valueForKey:kHomeAddress];
    if (homeAddress.length) {
        self.pageIndicatorContainer.hidden = NO;
    }
    else {
        self.pageIndicatorContainer.hidden = YES;
    }
}

- (void)configureCollectionView {
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // TODO: CREATE CONSTNATS FOR THESE
    [self.collectionView registerNib:[UINib nibWithNibName:@"RepsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"RepsCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AddAddressCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AddAddressCollectionViewCell"];
    self.collectionView.pagingEnabled = YES;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.minimumLineSpacing = 0.0;
    self.collectionView.collectionViewLayout = flowLayout;
}

#pragma mark - CollectionView Delegate Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]valueForKey:kHomeAddress];
    if (homeAddress.length) {
        return 3;
    }
    else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]valueForKey:kHomeAddress];

    if (homeAddress.length) {
        RepsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RepsCollectionViewCell" forIndexPath:indexPath];
        cell.tableViewDataSource = [[RepsManager sharedInstance]fetchRepsForIndex:indexPath.item];
        cell.index = indexPath.item;
        cell.repDetailDelegate = self;
        [cell reloadTableView];
        return cell;

    }
    else {
        AddAddressCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddAddressCollectionViewCell" forIndexPath:indexPath];
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.view.frame.size;
}

- (void)reloadCollectionView {
    [self.collectionView reloadData];
}

- (void)changePage:(NSNotification *)notification {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[notification.object integerValue] inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   
    NSArray *cellArray = self.collectionView.visibleCells;
    
    CGFloat viewHalfWidth = self.view.frame.size.width / 2;
    CGFloat midX = self.collectionView.contentOffset.x + viewHalfWidth;
    
    UICollectionViewCell *closestCell = self.collectionView.visibleCells.firstObject;
    CGFloat closestCellDistance = CGFLOAT_MAX;
    
    for (UICollectionViewCell *cell in cellArray) {
        CGFloat distance = fabs(cell.frame.origin.x + viewHalfWidth - midX);
        if (distance < closestCellDistance) {
            closestCellDistance = distance;
            closestCell = cell;
        }
    }
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:closestCell];
    
//    RootViewController *rootVC = (RootViewController *)self.parentViewController;
    [self updateTabForIndex:indexPath];
}

- (void)pushToDetailVC: (RepDetailViewController*) repVC {
    
    [self.parentViewController.navigationController pushViewController:repVC animated:YES];
}

#pragma mark - Page Indicator Container

- (IBAction)federalButtonDidPress:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"jumpPage" object:@0];

}
- (IBAction)stateButtonDidPress:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"jumpPage" object:@1];
   
}
- (IBAction)localButtonDidPress:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"jumpPage" object:@2];

}

- (void)setPageIndicator:(NSNotification *)notification {
        long int pageNumber = [notification.object integerValue];
        if (pageNumber == 0) {
            [self.federalButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        else if (pageNumber == 1) {
            [self.stateButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        else if (pageNumber == 2) {
            [self.localButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
//        [self presentScriptDialog];
    
}

- (void)updateTabForIndex:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath != indexPath) {
        
        UIButton *newButton = [self.buttonDictionary objectForKey:[NSNumber numberWithInteger:indexPath.item]];
        UIButton *lastButton = [self.buttonDictionary objectForKey:[NSNumber numberWithInteger:self.selectedIndexPath.item]];
        
        if (newButton == lastButton) {
            return;
        }
        
        [newButton.layer removeAllAnimations];
        [lastButton.layer removeAllAnimations];
        
        [UIView animateWithDuration:.25 animations:^{
            
            newButton.tintColor = [UIColor voicesBlue];
            lastButton.tintColor = [UIColor voicesLightGray];
            
        }];
        self.selectedIndexPath = indexPath;
    }
}


@end
