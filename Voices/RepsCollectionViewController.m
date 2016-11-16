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
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RepsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RepsCollectionViewCell" forIndexPath:indexPath];
    
    if (indexPath.item == 0) {
        cell.tableViewDataSource = [[NewManager sharedInstance]fetchRepsForIndex:0];
        
    }
    else if (indexPath.item == 1) {
        cell.tableViewDataSource = [[NewManager sharedInstance]fetchRepsForIndex:1];
    }
    else if (indexPath.item == 2) {
        cell.tableViewDataSource = [[NewManager sharedInstance]fetchRepsForIndex:2];
    }
    
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

@end
