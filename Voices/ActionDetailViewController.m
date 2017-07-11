//
//  ActionDetailViewController.m
//  Voices
//
//  Created by John Bogil on 6/10/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailViewController.h"
#import "STPopupController.h"
#import "SearchViewController.h"
#import "ActionDetailTopTableViewCell.h"
#import "RepTableViewCell.h"
#import "ActionDetailEmptyRepTableViewCell.h"
#import "RepsManager.h"

@interface ActionDetailViewController () <UITableViewDelegate, UITableViewDataSource, ExpandActionDescriptionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listOfReps;
@property (strong, nonatomic) NSArray *testArray;
    
@end

@implementation ActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    self.title = self.group.name;
    [self configureDatasource];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSearchViewController) name:@"presentSearchViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewFromNotification) name:@"endFetchingReps" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentScriptView) name:@"presentScriptView" object:nil];
    
    self.testArray = @[@"More Info",@"What to say (Call Script)",@"Share action"];
}

- (void)configureDatasource {
    
    if (self.action.level == 0) {
        self.listOfReps = [RepsManager sharedInstance].fedReps;
    }
    else if (self.action.level == 1) {
        self.listOfReps = [RepsManager sharedInstance].stateReps;
    }
    else if (self.action.level == 2) {
        self.listOfReps = [RepsManager sharedInstance].localReps;
    }
}

- (void)configureTableView {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ActionDetailTopTableViewCell" bundle:nil]forCellReuseIdentifier:@"ActionDetailTopTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:kRepTableViewCell bundle:nil]forCellReuseIdentifier:kRepTableViewCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActionDetailEmptyRepTableViewCell" bundle:nil]forCellReuseIdentifier:@"ActionDetailEmptyRepTableViewCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.allowsSelection = NO;
    
    self.tableView.estimatedRowHeight = 300.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)reloadTableViewFromNotification {
    
    [self configureDatasource];
    [self.tableView reloadData];
}

- (void)expandActionDescription:(ActionDetailTopTableViewCell *)sender {
    
    [self.tableView reloadData];
}

- (void)presentScriptView {
    
    UIViewController *infoViewController = (UIViewController *)[[[NSBundle mainBundle] loadNibNamed:@"ScriptDialog" owner:self options:nil] objectAtIndex:0];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:infoViewController];
    popupController.containerView.layer.cornerRadius = 10;
    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor]; // This is the only OK "orangeColor", for now
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:23], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[STPopupNavigationBar class]]] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:19] } forState:UIControlStateNormal];
    [popupController presentInViewController:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    if (self.listOfReps.count) {
//        return self.listOfReps.count + 1;
//    }
//    else return 2;
    if (self.listOfReps.count) {
        return self.listOfReps.count + self.testArray.count + 1;
    }
    else {
        return self.listOfReps.count + self.testArray.count + 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        ActionDetailTopTableViewCell *cell = (ActionDetailTopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionDetailTopTableViewCell" forIndexPath:indexPath];
        [cell initWithAction:self.action andGroup:self.group];
        cell.delegate = self;
        return cell;
    }
    else if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3){
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.textLabel.text = self.testArray[indexPath.row-1];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"AddGroup"]];
        cell.accessoryView.tintColor = [UIColor orangeColor];
        [cell.accessoryView setFrame:CGRectMake(0, 0, 20, 20)];
        
        return cell;
    }
    else {
        if (self.listOfReps.count) {
            RepTableViewCell *cell = (RepTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kRepTableViewCell forIndexPath:indexPath];
            [cell initWithRep:self.listOfReps[indexPath.row-4]];
            return cell;
        }
        else {
            ActionDetailEmptyRepTableViewCell *cell = (ActionDetailEmptyRepTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionDetailEmptyRepTableViewCell" forIndexPath:indexPath];
            return cell;
        }
    }
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.listOfReps.count && indexPath.row > 0) {
        return 140.0f;
    }
    else {
        return 300.0f;
    }
}

- (void)presentSearchViewController {
    
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    SearchViewController *searchViewController = (SearchViewController *)[repsSB instantiateViewControllerWithIdentifier:@"SearchViewController"];
    searchViewController.isHomeAddressVC = YES;
    searchViewController.title = @"Add Home Address";
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:searchViewController animated:YES];
}
@end
