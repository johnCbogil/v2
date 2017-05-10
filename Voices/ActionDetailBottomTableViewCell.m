//
//  ActionDetailBottomTableViewCell.m
//  Voices
//
//  Created by John Bogil on 3/26/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailBottomTableViewCell.h"
#import "ActionRepCollectionViewCell.h"
#import "RepsManager.h"

@interface ActionDetailBottomTableViewCell()

@property (strong, nonatomic) Representative *selectedRep;

@end

@implementation ActionDetailBottomTableViewCell

- (void)initWithAction:(Action *)action {
    
    self.action = action;
    
    [self configureActivityIndicator];
    [self configureGetRepsButton];
    [self configureRepSelectionFeature];
    [self configureDescriptionForActionText:action.body];
    
    self.selectRepLabel.font = [UIFont voicesFontWithSize:23];
    self.getRepsButton.backgroundColor = [UIColor clearColor];
    self.getRepsButton.titleLabel.font = [UIFont voicesFontWithSize:23];
    
    [self.getRepsButton setTitle:@"Add Address To Show Reps" forState:UIControlStateNormal];

    [self.collectionView reloadData];
}

- (void)configureRepSelectionFeature {
    
    [self configureCollectionView];
    
    if ([RepsManager sharedInstance].fedReps.count) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.indicatorView.hidden = NO;
            [self.indicatorView startAnimating];
        });
        self.repsArray = [[RepsManager sharedInstance] fetchRepsForIndex:self.action.level];
    }
    else {
        self.getRepsButton.hidden = NO;
        self.selectRepLabel.hidden = YES;
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
    self.selectRepLabel.hidden = NO;
}

- (void)configureDescriptionForActionText:(NSString *)text {
    
    self.descriptionTextView.font = [UIFont voicesFontWithSize:21];
    self.descriptionTextView.text = text;
    self.descriptionTextView.editable = NO;
    self.descriptionTextView.backgroundColor = [UIColor clearColor];
    self.descriptionTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.descriptionTextView.delegate = self;
}

- (IBAction)getRepsButtonDidPress:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"presentSearchViewController" object:nil];
}

# pragma mark - UICollectionView Methods

- (void)configureCollectionView {
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionViewLayout.minimumLineSpacing = 50.0f;
    [self.collectionView registerNib:[UINib nibWithNibName:@"ActionRepCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ActionRepCollectionViewCell"];
    self.collectionView.backgroundColor = [UIColor clearColor];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.repsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ActionRepCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ActionRepCollectionViewCell" forIndexPath:indexPath];
    Representative *rep = self.repsArray[indexPath.row];
    [cell setupWithRepresentative:rep];
    [cell configureAsSelected:[self.selectedRep.fullName isEqualToString:rep.fullName]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (self.repsArray.count) {
        self.selectedRep = self.repsArray[indexPath.row];
        self.selectRepLabel.text = [NSString stringWithFormat:@"Selected Rep: %@", self.selectedRep.fullName];
        [self selectRep:self.selectedRep];
        
        ActionRepCollectionViewCell *selectedCell = (ActionRepCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        for (ActionRepCollectionViewCell *cell in collectionView.visibleCells) {
            [cell configureAsSelected:[cell isEqual:selectedCell]];
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // Add inset to the collection view if there are not enough cells to fill the width.
    CGFloat cellSpacing = ((UICollectionViewFlowLayout *) collectionViewLayout).minimumLineSpacing;
    CGFloat cellWidth = ((UICollectionViewFlowLayout *) collectionViewLayout).itemSize.width;
    NSInteger cellCount = [collectionView numberOfItemsInSection:section];
    CGFloat inset = (collectionView.bounds.size.width - (cellCount * cellWidth) - ((cellCount - 1)*cellSpacing)) * 0.5;
    inset = MAX(inset, 0.0);
    return UIEdgeInsetsMake(0.0, inset, 0.0, 0.0);
}

- (void)selectRep:(Representative *)rep {
    
    [self.delegate selectRep:rep];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    [self.delegate presentWebViewControllerFromTextView:URL withTitle:@"TAKE ACTION"];

    return NO;
}

@end
