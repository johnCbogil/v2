//
//  ActionWebViewController.m
//  Voices
//
//  Created by Jesse Sahli on 10/21/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ActionWebViewController.h"

@interface ActionWebViewController ()

@end

@implementation ActionWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TAKE ACTION";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    UIWebView *webView = [[UIWebView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.linkURL];
    [webView loadRequest:urlRequest];
    webView.scalesPageToFit = YES;
    webView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:webView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

@end
