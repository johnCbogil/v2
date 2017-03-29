//
//  NewActionDetailBottomTableViewCell.m
//  Voices
//
//  Created by John Bogil on 3/26/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailBottomTableViewCell.h"
#import "ActionRepCollectionViewCell.h"

// TODO: IMPLEMENT COLLECTIONVIEW DELEGATE
// TODO: CONFIGURE COLLECTIONVIEW
// TODO: SET THE DESCRIPTION TEXT
// TODO: FIND THE REPS

// cell 2 delegates to the controller, controller stores the state and can update cell 1

// Send rep.m from bottom cell to viewcontroller
// delegate is always the first one (the viewcontroller in this case)


@implementation NewActionDetailBottomTableViewCell

- (void)initWithAction:(Action *)action {
    
    [self configureDescriptionForActionText:action.body];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellEditingStyleNone;
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
    //    collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
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
        [self selectRepForCurrentAction:self.selectedRep];
        ActionRepCollectionViewCell *selectedCell = (ActionRepCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        for (ActionRepCollectionViewCell *cell in self.listOfRepCells) {
            if (selectedCell == cell) {
                cell.layer.borderColor = [UIColor greenColor].CGColor;
                cell.layer.borderWidth = 2.0f;
            }
            else {
                cell.layer.borderColor = [UIColor clearColor].CGColor;
            }
        }
    }
}

- (void)selectRepForCurrentAction:(Representative *)rep {
    
    [self.delegate sendRepToViewController:rep];
}

@end
