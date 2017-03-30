//
//  NewActionDetailBottomTableViewCell.m
//  Voices
//
//  Created by John Bogil on 3/26/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailBottomTableViewCell.h"
#import "ActionRepCollectionViewCell.h"
#import "RepsManager.h"

@implementation NewActionDetailBottomTableViewCell

- (void)initWithAction:(Action *)action {
    
    self.repsArray = [[RepsManager sharedInstance]fetchRepsForIndex:action.level];
    self.listOfRepCells = @[].mutableCopy;
    [self.collectionView reloadData];
    [self configureDescriptionForActionText:action.body];
    [self configureCollectionView];
    [self configureActivityIndicator];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellEditingStyleNone;
}

- (void)configureActivityIndicator {
    
    self.indicatorView = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.color = [UIColor grayColor];
    self.indicatorView.frame = CGRectMake(0, 0, 30.0f, 30.0f);
    self.indicatorView.hidden = false;
    self.indicatorView.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:self.indicatorView];
    
    NSLayoutConstraint *horizontalConstraint = [self.indicatorView.centerXAnchor constraintEqualToAnchor: self.centerXAnchor];
    NSLayoutConstraint *verticalConstraint = [self.indicatorView.centerYAnchor constraintEqualToAnchor:self.bottomAnchor constant: - self.frame.size.height/6];
    NSArray *constraints = [[NSArray alloc]initWithObjects:horizontalConstraint, verticalConstraint, nil];
    [NSLayoutConstraint activateConstraints:constraints];
}


- (void)configureDescriptionForActionText:(NSString *)text {
    
    self.descriptionTextView.font = [UIFont voicesFontWithSize:21];
    self.descriptionTextView.text = text;
    self.descriptionTextView.editable = NO;
    self.descriptionTextView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

# pragma mark - UICollectionView Methods

- (void)configureCollectionView {
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
//        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
    [self.collectionView registerNib:[UINib nibWithNibName:@"ActionRepCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ActionRepCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.repsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ActionRepCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ActionRepCollectionViewCell" forIndexPath:indexPath];
    [cell initWithRep:self.repsArray[indexPath.row]];
    [self.listOfRepCells addObject:cell];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (self.repsArray.count) {
        self.selectedRep = self.repsArray[indexPath.row];
        self.selectRepLabel.text = [NSString stringWithFormat:@"Selected Rep: %@", self.selectedRep.fullName];
        [self selectRepForCurrentAction:self.selectedRep];
        ActionRepCollectionViewCell *selectedCell = (ActionRepCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        for (ActionRepCollectionViewCell *cell in self.listOfRepCells) {
            if (selectedCell == cell) {
                cell.layer.borderColor = [UIColor greenColor].CGColor;
                cell.layer.borderWidth = 3.0f;
            }
            else {
                cell.layer.borderColor = [UIColor clearColor].CGColor;
            }
        }
    }
}

// CENTER REPS IN VIEW
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    
//    NSInteger numberOfItems = [collectionView numberOfItemsInSection:section];
//    CGFloat combinedItemWidth = (numberOfItems * collectionViewLayout.itemSize.width) + ((numberOfItems - 1) * collectionViewLayout.minimumInteritemSpacing);
//    CGFloat padding = (collectionView.frame.size.width - combinedItemWidth) / 2;
//    
//    return UIEdgeInsetsMake(0, padding, 0, padding);
//}

- (void)selectRepForCurrentAction:(Representative *)rep {
    
    [self.delegate sendRepToViewController:rep];
}

@end
