//
//  WebViewController.m
//  Voices
//
//  Created by John Bogil on 2/15/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureNavigationController];
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.delegate = self;
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:urlRequest];
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
    [self createActivityIndicator];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationItem setBackBarButtonItem:nil];
}

- (void)configureNavigationController {
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem setBackBarButtonItem:nil];
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
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
