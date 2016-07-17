//
//  TabBarViewController.m
//  Voices
//
//  Created by John Bogil on 4/17/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "TabBarViewController.h"
#import "UIColor+voicesColor.h"
#import "UIFont+voicesFont.h"
#import "VoicesConstants.h"
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
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle:nil];
    
    RootViewController *rootVC = (RootViewController *)[repsSB instantiateViewControllerWithIdentifier: @"RootViewController"];
    GroupsViewController *groupsVC = (GroupsViewController *)[groupsSB instantiateViewControllerWithIdentifier: @"GroupsNavigationViewController"];
    
    self.viewControllers = @[rootVC, groupsVC];
}

- (void)createTabBarButtons {
    
    UITabBarItem *repsTab = [self.tabBar.items objectAtIndex:0];
    repsTab.title = @"Reps";
    repsTab.image = [UIImage imageNamed:@"Triangle"];
    
    UITabBarItem *groupsTab = [self.tabBar.items objectAtIndex:1];
    groupsTab.title = @"Groups";
    groupsTab.image = [UIImage imageNamed:@"GroupIcon"];
    
}

@end
