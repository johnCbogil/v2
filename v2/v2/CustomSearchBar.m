//
//  CustomSearchBar.m
//  v2
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "CustomSearchBar.h"

@implementation CustomSearchBar

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])){
        UIView *customSearchBarView =[[[NSBundle mainBundle] loadNibNamed:@"CustomSearchBarView"
                                                                    owner:self
                                                                  options:nil] objectAtIndex:0];
        [self addSubview:customSearchBarView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeLabel:)
                                                     name:@"changeLabel"
                                                   object:nil];
    }
    return self;
}

- (void)awakeFromNib {
    
    self.searchBar.delegate = self;
    
    [self hideSearchBar];
    
    // ROUND THE BOX
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    
    // Set cancel button to white color
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]forState:UIControlStateNormal];
    
    // Set placeholder text to white
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil]setTextColor:[UIColor whiteColor]];
    
    // Set the input text font
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setDefaultTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Avenir" size:15],NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // HIDE THE MAGNYIFYING GLASS
    [self.searchBar setImage:[UIImage new]
            forSearchBarIcon:UISearchBarIconSearch
                       state:UIControlStateNormal];
    
    // SET THE CURSOR POSITION
    [[UISearchBar appearance] setPositionAdjustment:UIOffsetMake(-20, 0)
                                   forSearchBarIcon:UISearchBarIconSearch];
    
    [self.searchBar setTintColor:[UIColor whiteColor]];
    
    // SET THE CURSOR COLOR
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setTintColor:[UIColor colorWithRed:255.0 / 255.0
                                  green:160.0 / 255.0
                                   blue:5.0 / 255.0
                                  alpha:1.0]];
    
    // SET THE CLEAR BUTTON FOR BOTH STATES
    [self.searchBar setImage:[UIImage imageNamed:@"ClearButton"]
            forSearchBarIcon:UISearchBarIconClear
                       state:UIControlStateHighlighted];
    [self.searchBar setImage:[UIImage imageNamed:@"ClearButton"]
            forSearchBarIcon:UISearchBarIconClear
                       state:UIControlStateNormal];
    
    // ROUND THE SEARCH BAR
    UITextField *txfSearchField = [self.searchBar valueForKey:@"_searchField"];
    txfSearchField.layer.cornerRadius = 13;
    
    
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [ self hideSearchBar];
}

- (IBAction)openSearchBarButtonDidPress:(id)sender {
    [self showSearchBar];
}

- (void)showSearchBar {
    self.isSearchBarOpen = YES;
    [self.searchBar becomeFirstResponder];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.searchBar.alpha = 1.0;
                         self.singleLineView.alpha = 0.0;
                         self.legislatureLevel.alpha = 0.0;
                         self.openSearchBarButton.alpha = 0.0;
                     }];
}

- (void)hideSearchBar {
    self.isSearchBarOpen = NO;
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.searchBar.alpha = 0.0;
                         self.openSearchBarButton.alpha = 1.0;
                         self.legislatureLevel.alpha = 1.0;
                         self.singleLineView.alpha = 1.0;

                     }];
}

- (void)changeLabel:(NSNotification*)notification {
    NSDictionary* userInfo = notification.object;
    self.legislatureLevel.text = [userInfo valueForKey:@"currentPage"];
}
@end