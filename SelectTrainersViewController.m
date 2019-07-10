//
//  SelectTrainersViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/16/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "SelectTrainersViewController.h"

@interface SelectTrainersViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *trainers;
@property NSMutableArray *selection;

@end

@implementation SelectTrainersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self getTrainers];
        _selection = [[NSMutableArray alloc] init];

}

-(void)viewDidAppear:(BOOL)animated
{
    [self getTrainers];
    if ([_trainers count]==0){
        [self showPrompt];
        
    }

    
}

-(void)getTrainers
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSObject * object = [prefs objectForKey:@"trainers"];
    if(object != nil){
        if (![_trainers isEqualToArray: [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"trainers"]]]){
            _trainers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"trainers"]];
            [_tableView reloadData];
            _selection = [[NSMutableArray alloc] init];
        }
        
        
    }
    else{
        _trainers = [[NSMutableArray alloc] init];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _trainers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SelectTrainerCell";
    EmployeeCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[EmployeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    cell.passNumber.text =  [_trainers objectAtIndex:indexPath.row][0];
    cell.name.text = [_trainers objectAtIndex:indexPath.row][1];
  
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:137.0f/255.0f green:157.0f/255.0f blue:188.0f/255.0f alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    EmployeeCell *cell = (EmployeeCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSArray *namePassPair = [[NSArray alloc] initWithObjects:cell.passNumber.text,cell.name.text, nil];
    [_selection addObject:namePassPair];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    EmployeeCell *cell = (EmployeeCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSArray *namePassPair = [[NSArray alloc] initWithObjects:cell.passNumber.text,cell.name.text, nil];
    [_selection removeObject:namePassPair];
}

- (IBAction)resetSelection:(id)sender {
    [_tableView reloadData];
    [_selection removeAllObjects];
}

- (IBAction)backButton:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)nextButton:(id)sender {
    if ([_selection count]!=0){
        [self passInformation];
        [self.tabBarController setSelectedIndex:2];
    }
    else{
        UIAlertController * alert=    [UIAlertController
                                       alertControllerWithTitle:@"Error"
                                       message:@"Please select at least one trainer."
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];

        
    }
    
}
-(void)showPrompt
{
    UIAlertController * alert=    [UIAlertController
                                   alertControllerWithTitle:@"Welcome"
                                   message:@"You have not registered any trainers to this device yet. Please register yourself as a trainer by clicking the prompt at the bottom of the screen."
                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)passInformation
{
    ScanEmployeesViewController *scanVC = (ScanEmployeesViewController *) [self.tabBarController viewControllers][2];
    scanVC.selectedTrainers = _selection;
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
