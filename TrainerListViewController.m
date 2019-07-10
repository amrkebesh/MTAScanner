//
//  TrainerListViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/16/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "TrainerListViewController.h"

@interface TrainerListViewController ()

@end

@implementation TrainerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.allowsSelection=NO;
    
    [self getTrainers];
    

    // Do any additional setup after loading the view.
}



-(void)getTrainers
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSObject * object = [prefs objectForKey:@"trainers"];
    if(object != nil){
        _trainers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"trainers"]];
        
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
    static NSString *cellIdentifier = @"TrainerCell";
    EmployeeCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.list = self;
    [cell.removeButton addTarget:cell action:@selector(removeTrainer) forControlEvents:UIControlEventTouchDown];
    
    if(cell == nil) {
        cell = [[EmployeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    cell.name.text =  [_trainers objectAtIndex:indexPath.row][1];
    cell.passNumber.text =[_trainers objectAtIndex:indexPath.row][0];
    return cell;
}

-(void)removeTrainer{
   //For removing trainers from lis with "remove button" (EmployeeCell)
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
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
