//
//  NewActionDetailTableViewCell.m
//  Voices
//
//  Created by John Bogil on 3/20/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailTableViewCell.h"
#import "ActionRepCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "RepsManager.h"
#import "Representative.h"

@interface NewActionDetailTableViewCell() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *groupLogo;
@property (weak, nonatomic) IBOutlet UILabel *actionTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *selectRepLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) Action *action;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) Representative *selectedRep;
@property (strong, nonatomic) NSMutableArray *listOfRepCells;

@end

@implementation NewActionDetailTableViewCell

- (void)initWithGroup:(Group *)group andAction:(Action *)action {
    
    [self fetchGroupLogoForImageURL:group.groupImageURL];
    self.group = group;
    self.action = action;
    self.repsArray = [[RepsManager sharedInstance]fetchRepsForIndex:self.action.level];
    [self.collectionView reloadData];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ActionRepCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ActionRepCollectionViewCell"];
    self.listOfRepCells = @[].mutableCopy;
    self.collectionView.backgroundColor = [UIColor clearColor];
//    self.callButton.tintColor = [UIColor voicesOrange];
//    self.emailButton.tintColor = [UIColor voicesOrange];
//    self.tweetButton.tintColor = [UIColor voicesOrange];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)fetchGroupLogoForImageURL:(NSURL *)url {
    
    self.groupLogo.backgroundColor = [UIColor clearColor];
    self.groupLogo.imageView.contentMode = UIViewContentModeScaleToFill;
    self.groupLogo.imageView.layer.cornerRadius = kButtonCornerRadius;
    self.groupLogo.imageView.clipsToBounds = YES;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    [self.groupLogo.imageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        NSLog(@"Group image success");
        [UIView animateWithDuration:.25 animations:^{
            [self.groupLogo setBackgroundImage:image forState:UIControlStateNormal];
        }];
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        [UIView animateWithDuration:.25 animations:^{
            [self.groupLogo setBackgroundImage:[UIImage imageNamed:kGroupDefaultImage] forState:UIControlStateNormal];
        }];
        NSLog(@"Action image failure");
    }];
}

#pragma mark - UICollectionView Delegate methods

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
//        self.chooseRepsLabel.text = [NSString stringWithFormat:@"Select A Rep: %@", self.selectedRep.fullName ];
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

@end
