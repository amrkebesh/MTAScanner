//
//  OfflineEditScansViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 9/7/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "OfflineEditScansViewController.h"

@interface OfflineEditScansViewController ()

@end

@implementation OfflineEditScansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.allowsSelection=NO;
    // Do any additional setup after loading the view.
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
    return _scans.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"EmployeeCell";
    EmployeeCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.list = self;
    cell.employees = _scans;
    [cell.removeButton addTarget:cell action:@selector(removeEmployee) forControlEvents:UIControlEventTouchDown];
    if(cell == nil) {
        cell = [[EmployeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    
    cell.name.text =  [_scans objectAtIndex:indexPath.row];
    
    
    return cell;
}

-(void)removeEmployee
{
    //Button Action for removing employee from scanned list
}

-(IBAction)removeTrainer:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:buttonPosition];
    [_scans removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
}

- (IBAction)doneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
