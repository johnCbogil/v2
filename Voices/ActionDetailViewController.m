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
#import "ActionDetailMenuItemTableViewCell.h"
#import "RepsManager.h"

@interface ActionDetailViewController () <UITableViewDelegate, UITableViewDataSource, ExpandActionDescriptionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listOfReps;
@property (strong, nonatomic) NSArray *listOfMenuItems;
@property (nonatomic) NSInteger indexPathRowToExpand;
@end

// TODO: IMPLEMENT SHARE ACTION FUNCTIONALITY

@implementation ActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    self.title = self.group.name;
    [self configureDatasource];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSearchViewController) name:@"presentSearchViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewFromNotification) name:@"endFetchingReps" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentScriptView) name:@"presentScriptView" object:nil];
    
    self.listOfMenuItems = @[@"Why it's important",@"What to say (Call Script)",@"Share action"];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"ActionDetailMenuItemTableViewCell" bundle:nil]forCellReuseIdentifier:@"ActionDetailMenuItemTableViewCell"];
    
//    self.tableView.separatorColor = [UIColor clearColor];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
//    self.tableView.allowsSelection = NO;
    
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

//- (void)presentScriptView {
//    
//    UIViewController *infoViewController = (UIViewController *)[[[NSBundle mainBundle] loadNibNamed:@"ScriptDialog" owner:self options:nil] objectAtIndex:0];
//    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:infoViewController];
//    popupController.containerView.layer.cornerRadius = 10;
//    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor]; // This is the only OK "orangeColor", for now
//    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
//    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
//    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:23], NSForegroundColorAttributeName: [UIColor whiteColor] };
//    popupController.transitionStyle = STPopupTransitionStyleFade;
//    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[STPopupNavigationBar class]]] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:19] } forState:UIControlStateNormal];
//    [popupController presentInViewController:self];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.listOfReps.count) {
        return self.listOfReps.count + self.listOfMenuItems.count + 2;
    }
    else {
        return self.listOfReps.count + self.listOfMenuItems.count + 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        ActionDetailTopTableViewCell *cell = (ActionDetailTopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionDetailTopTableViewCell" forIndexPath:indexPath];
        [cell initWithAction:self.action andGroup:self.group];
        cell.delegate = self;
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3){
        
        ActionDetailMenuItemTableViewCell *cell = (ActionDetailMenuItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionDetailMenuItemTableViewCell" forIndexPath:indexPath];
        cell.itemTitle.numberOfLines = 0;
        if (self.indexPathRowToExpand == indexPath.row) {
            if (indexPath.row == 1) {
                cell.itemTitle.text = self.action.body;
            }
            else if (indexPath.row == 2) {
                cell.itemTitle.text = self.action.script;
            }
        }
        else {
            cell.itemTitle.text = self.listOfMenuItems[indexPath.row-1];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"AddGroup"]];
        cell.accessoryView.tintColor = [UIColor orangeColor];
        [cell.accessoryView setFrame:CGRectMake(0, 0, 20, 20)];
        
        return cell;
    }
    else if (indexPath.row == 4) {
        UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.textLabel.font = [UIFont voicesBoldFontWithSize:21];
            cell.textLabel.text = @"Take Action";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            
        }
        return cell;
    }
    else {
        if (self.listOfReps.count) {
            RepTableViewCell *cell = (RepTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kRepTableViewCell forIndexPath:indexPath];
            [cell initWithRep:self.listOfReps[indexPath.row-4]];
            cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
            return cell;
        }
        else {
            ActionDetailEmptyRepTableViewCell *cell = (ActionDetailEmptyRepTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionDetailEmptyRepTableViewCell" forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.indexPathRowToExpand == indexPath.row) {
        self.indexPathRowToExpand = 0;
    }
    else if (indexPath.row == 1 || indexPath.row == 2) {
        self.indexPathRowToExpand = indexPath.row;
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
