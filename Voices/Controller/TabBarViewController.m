//
//  TabBarViewController.m
//  Voices
//
//  Created by John Bogil on 4/17/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "TabBarViewController.h"
#import "TakeActionViewController.h"
#import "RootViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createViewControllers];
    [self createTabBarButtons];
    
    self.navigationController.navigationBarHidden = YES;
    [UITabBar appearance].tintColor = [UIColor voicesOrange];
}

- (void)createViewControllers {

    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle:nil];
    UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
    
    UIViewController *rootVC = [repsSB instantiateViewControllerWithIdentifier: @"RepsNavCtrl"];
    TakeActionViewController *groupsVC = (TakeActionViewController *)[takeActionSB instantiateViewControllerWithIdentifier: @"TakeActionNavigationViewController"];
    
    self.viewControllers = @[rootVC, groupsVC];
}

- (void)createTabBarButtons {
    
    UITabBarItem *repsTab = [self.tabBar.items objectAtIndex:0];
    repsTab.title = @"My Reps";
    repsTab.image = [UIImage imageNamed:@"triangle"];
    
    if (self.tabBar.items.count > 1) {
        UITabBarItem *groupsTab = [self.tabBar.items objectAtIndex:1];
        groupsTab.title = @"My Actions";
        groupsTab.image = [UIImage imageNamed:@"groupIcon"];
    }
}

@end
