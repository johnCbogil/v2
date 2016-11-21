//
//  RepsCollectionViewController.m
//  Voices
//
//  Created by Bogil, John on 11/11/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepsCollectionViewController.h"
#import "RepsCollectionViewCell.h"
#import "NewManager.h"

@implementation RepsCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"RepsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"RepsCollectionViewCell"];
    self.collectionView.pagingEnabled = YES;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.minimumLineSpacing = 0.0;
    self.collectionView.collectionViewLayout = flowLayout;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadCollectionView) name:@"reloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage:) name:@"jumpPage" object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - CollectionView Delegate Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RepsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RepsCollectionViewCell" forIndexPath:indexPath];
    
    cell.tableViewDataSource = [[NewManager sharedInstance]fetchRepsForIndex:indexPath.item];
    
    cell.index = indexPath.item;
    
    [cell reloadTableView];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.view.frame.size;
}

- (void)reloadCollectionView {
    [self.collectionView reloadData];
}

- (void)changePage:(NSNotification *)notification {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[notification.object integerValue] inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

@end
