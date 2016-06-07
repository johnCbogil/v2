//
//  TabBarViewController.m
//  Voices
//
//  Created by John Bogil on 4/17/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "TabBarViewController.h"
#import "UIColor+voicesOrange.h"
#import "RootViewController.h"
#import "AdvocacyGroupsViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createViewControllers];
    [self createTabBarButtons];
    
    [UITabBar appearance].tintColor = [UIColor voicesOrange];
}

- (void)createViewControllers {
    
    UIStoryboard *groupsSB = [UIStoryboard storyboardWithName:@"AdvocacyGroups" bundle: nil];
    UIStoryboard *actionsSB = [UIStoryboard storyboardWithName:@"Actions" bundle:nil];
    
    RootViewController *rootVC = (RootViewController *)[actionsSB instantiateViewControllerWithIdentifier: @"RootViewController"];
    AdvocacyGroupsViewController *groupsVC = (AdvocacyGroupsViewController *)[groupsSB instantiateViewControllerWithIdentifier: @"AdvocacyGroupsNavigationViewController"];
    
    self.viewControllers = @[rootVC, groupsVC];
}

- (void)createTabBarButtons {
    
    [[self.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"Triangle"]];
    [[self.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"Circle"]];
    
    for(UITabBarItem * tabBarItem in self.tabBar.items){
        tabBarItem.title = @"";
        tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
}

@end
