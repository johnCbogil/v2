//
//  RepsCollectionViewCell.h
//  Voices
//
//  Created by John Bogil on 11/12/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepsCollectionViewCell : UICollectionViewCell <UITableViewDelegate, UITableViewDataSource>

- (void)initWithIndex:(NSInteger)integer;

@end
