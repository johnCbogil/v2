//
//  ActionWebViewController.m
//  Voices
//
//  Created by Jesse Sahli on 10/21/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ActionWebViewController.h"

@interface ActionWebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIWebView *webView;
@end

@implementation ActionWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TAKE ACTION";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    self.webView = [[UIWebView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.webView.delegate = self;
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.linkURL];
    [self.webView loadRequest:urlRequest];
    self.webView.scalesPageToFit = YES;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.webView];
    [self createActivityIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)createActivityIndicator {
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.color = [UIColor grayColor];
    self.activityIndicatorView.center = self.view.center;
    [self.view addSubview:self.activityIndicatorView];
    self.activityIndicatorView.hidden = NO;
    [self toggleActivityIndicatorOn];
}

- (void)toggleActivityIndicatorOn {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityIndicatorView.hidden = NO;
        [self.activityIndicatorView startAnimating];
    });
}

- (void)toggleActivityIndicatorOff {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityIndicatorView.hidden = YES;
        [self.activityIndicatorView stopAnimating];
    });
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //Check here if still webview is loding the content
    if (webView.isLoading) {
        return;
    }
    
    [self toggleActivityIndicatorOff];

}

@end
