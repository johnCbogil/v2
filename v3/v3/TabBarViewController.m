//
//  TabBarViewController.m
//  Voices
//
//  Created by John Bogil on 4/17/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "TabBarViewController.h"
#import "UIColor+voicesOrange.h"
#import "HomeViewController.h"
#import "AdvocacyGroupsViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [UITabBar appearance].tintColor = [UIColor voicesOrange];
    
    UIStoryboard *groupsSB = [UIStoryboard storyboardWithName:@"AdvocacyGroups" bundle: nil];
    UIStoryboard *actionsSB = [UIStoryboard storyboardWithName:@"Actions" bundle:nil];

    HomeViewController *homeVC = (HomeViewController *)[actionsSB instantiateViewControllerWithIdentifier: @"HomeViewController"];
    AdvocacyGroupsViewController *groupsVC = (AdvocacyGroupsViewController *)[groupsSB instantiateViewControllerWithIdentifier: @"AdvocacyGroupsNavigationViewController"];
    
    self.viewControllers = @[homeVC, groupsVC];
    
    [[self.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"Triangle"]];
    [[self.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"Circle"]];

    for(UITabBarItem * tabBarItem in self.tabBar.items){
        tabBarItem.title = @"";
        tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
}

@end
