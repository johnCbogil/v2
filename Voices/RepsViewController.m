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
@property (weak, nonatomic) IBOutlet UILabel *findingRepsLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation RepsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configurePageIndicator];
    [self configureCollectionView];
    [self createActivityIndicator];
    [self addObservers];
    
    self.buttonDictionary = @{@0 : self.federalButton, @1 : self.stateButton , @2 :self.localButton};
}

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionView) name:@"reloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage:) name:@"jumpPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPageIndicator:) name:@"actionPageJump" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleActivityIndicatorOn) name:@"startFetchingReps" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleActivityIndicatorOff) name:@"endFetchingReps" object:nil];
}

- (void)viewWillLayoutSubviews {
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)configurePageIndicator {
    
    self.federalButton.tintColor = [UIColor voicesBlue];
    self.stateButton.tintColor = [UIColor voicesLightGray];
    self.localButton.tintColor = [UIColor voicesLightGray];
    self.pageIndicatorContainer.hidden = YES;
}

- (void)configureCollectionView {
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:kRepsCollectionViewCell bundle:nil] forCellWithReuseIdentifier:kRepsCollectionViewCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kAddAddressCollectionViewCell bundle:nil] forCellWithReuseIdentifier:kAddAddressCollectionViewCell];
    self.collectionView.pagingEnabled = YES;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.minimumLineSpacing = 0.0;
    self.collectionView.collectionViewLayout = flowLayout;
}

- (void)createActivityIndicator {
    
    self.findingRepsLabel.font = [UIFont voicesFontWithSize:23];
    self.findingRepsLabel.hidden = YES;
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicatorView.color = [UIColor grayColor];
    self.activityIndicatorView.hidesWhenStopped = YES;
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (homeAddress) {
        [self toggleActivityIndicatorOn];
    }
}

- (void)toggleActivityIndicatorOn {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.findingRepsLabel.hidden = NO;
        self.collectionView.hidden = YES;
        [self.activityIndicatorView startAnimating];
    });
}

- (void)toggleActivityIndicatorOff {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.findingRepsLabel.hidden = YES;
        self.collectionView.hidden = NO;
        [self.activityIndicatorView stopAnimating];
    });
}

#pragma mark - CollectionView Delegate Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([RepsManager sharedInstance].fedReps.count) {
        return 3;
    }
    else {
        if (self.activityIndicatorView.hidden == NO) {
            return 0;
        }
        else {
            return 1;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    BOOL homeAddressSaved = homeAddress.length;
    
    if ([RepsManager sharedInstance].fedReps.count || homeAddressSaved) {
        
        RepsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRepsCollectionViewCell forIndexPath:indexPath];
        cell.tableViewDataSource = [[RepsManager sharedInstance]fetchRepsForIndex:indexPath.item];
        cell.index = indexPath.item;
        cell.repDetailDelegate = self;
        [cell reloadTableView];
        return cell;
    }
    else {
        
        AddAddressCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAddAddressCollectionViewCell forIndexPath:indexPath];
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.collectionView.frame.size;
}

- (void)reloadCollectionView {
    
    if ([RepsManager sharedInstance].fedReps.count) {
        self.pageIndicatorContainer.hidden = NO;
    }
    else {
        self.pageIndicatorContainer.hidden = YES;
    }
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
