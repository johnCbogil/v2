//
//  NewInfoViewController.m
//  Voices
//
//  Created by John Bogil on 12/26/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NewInfoViewController.h"
#import "InfoTableViewCell.h"
#import <STPopup/STPopup.h>

@interface NewInfoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NewInfoViewController

// TODO: MOVE TEXT TO CONSTANTS


- (instancetype)init {
    if (self = [super init]) {
        self.contentSizeInPopup = CGSizeMake(300, 315);
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"InfoTableViewCell" bundle:nil]forCellReuseIdentifier:@"InfoTableViewCell"];
    
    self.title = @"More Info";
    self.contentSizeInPopup = CGSizeMake(300, self.view.frame.size.height * .65);

    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    InfoTableViewCell *infoTableViewCell = [[InfoTableViewCell alloc]init];
    infoTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"InfoTableViewCell"];
    if (indexPath.row == 0) {
        infoTableViewCell.titleLabel.text = @"Why Call";
        infoTableViewCell.descriptionTextView.text = @"Calling the district office of your Congressional rep is the most effective way to get government to listen to you, according to political staffers. Calls are taken more seriously and make a greater impact than emails or written letters. Because your Congressional rep serves fewer constituents than a Senator, a call to your rep is more likely to be answered and carries more relative weight.";

    }
    else if (indexPath.row == 1) {
        infoTableViewCell.titleLabel.text = @"What to Say";
        infoTableViewCell.descriptionTextView.text = @"Hi, my name is [your name] and I'm a constituent from [your town/city]. I'm calling because [express your opinion on an issue here]. Please tell [rep name] to [support/oppose/speak out against] [your issue]. Thank you for your time.";
        
    }
    else if (indexPath.row == 2) {
        infoTableViewCell.titleLabel.text = @"What to Expect";
        infoTableViewCell.descriptionTextView.text = @"You will likely talk to an intern or Congressional staffer dedicated to constituent services. They will take down your name, opinion and relay that information for your representative. Many offices tally the number of constituents that call to support or oppose various issues.";

    }
    
    
    return infoTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150.0;
}




@end
