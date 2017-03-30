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


// TODO: HOW TO DISPLAY EMPTY STATE UX
// TODO: LOADING INDICATOR

@implementation NewActionDetailBottomTableViewCell

- (void)initWithAction:(Action *)action {
    
    self.action = action;
    
    [self configureActivityIndicator];
    [self configureGetRepsButton];
    [self configureRepSelectionFeature];
    [self configureDescriptionForActionText:action.body];


    self.listOfRepCells = @[].mutableCopy;
    [self.collectionView reloadData];
}

- (void)configureRepSelectionFeature {
    
    [self configureCollectionView];
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (homeAddress.length) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.indicatorView.hidden = NO;
            [self.indicatorView startAnimating];
        });
        self.repsArray = [[RepsManager sharedInstance]fetchRepsForIndex:self.action.level];
    }
    else {
        self.getRepsButton.hidden = NO;
    }
    
    if (self.repsArray.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView stopAnimating];
            self.indicatorView.hidden = YES;
        });
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellEditingStyleNone;
}

- (void)configureActivityIndicator {
    
    self.indicatorView.hidden = YES;
    self.indicatorView.color = [UIColor grayColor];
    self.indicatorView.translatesAutoresizingMaskIntoConstraints = false;
}

- (void)configureGetRepsButton {
    
    self.getRepsButton.hidden = YES;
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

- (IBAction)getRepsButtonDidPress:(id)sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"presentSearchViewController" object:nil];
    
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

- (void)selectRepForCurrentAction:(Representative *)rep {
    
    [self.delegate sendRepToViewController:rep];
}

@end
