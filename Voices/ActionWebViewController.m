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
    UIWebView *webView = [[UIWebView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.linkURL];
    [webView loadRequest:urlRequest];
    webView.scalesPageToFit = YES;
    webView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:webView];
    
}


@end
