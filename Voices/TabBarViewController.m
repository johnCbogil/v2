//
//  TabBarViewController.m
//  Voices
//
//  Created by John Bogil on 4/17/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "TabBarViewController.h"
#import "UIColor+voicesColor.h"
#import "GroupsViewController.h"
#import "RootViewController.h"

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
    
    UIStoryboard *groupsSB = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    UIStoryboard *actionsSB = [UIStoryboard storyboardWithName:@"Actions" bundle:nil];
    
    RootViewController *rootVC = (RootViewController *)[actionsSB instantiateViewControllerWithIdentifier: @"RootViewController"];
    GroupsViewController *groupsVC = (GroupsViewController *)[groupsSB instantiateViewControllerWithIdentifier: @"GroupsNavigationViewController"];
    
    self.viewControllers = @[rootVC, groupsVC];
}

- (void)createTabBarButtons {
    
    UITabBarItem *repsTab = [self.tabBar.items objectAtIndex:0];// setImage:[UIImage imageNamed:@"Triangle"]];
    repsTab.title = @"REPS";
    repsTab.image = [UIImage imageNamed:@"Triangle"];
    
    UITabBarItem *groupsTab = [self.tabBar.items objectAtIndex:1];
    groupsTab.title = @"GROUPS";
    groupsTab.image = [UIImage imageNamed:@"GroupIcon"];
    
//    for(UITabBarItem * tabBarItem in self.tabBar.items){
//        tabBarItem.title = @"";
//        tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
//    }
}

@end
