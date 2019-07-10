//
//  FacilityListViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/22/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "FacilityListViewController.h"

@interface FacilityListViewController ()
@property NSMutableArray *facilities;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;
@property NSArray *searchResults;

@end

@implementation FacilityListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _facilities = [[NSMutableArray alloc] init];
    [self populateTable];
    _table.delegate=self;
    _table.dataSource=self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [_searchbar becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (IBAction)doneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)populateTable
{
    //NSString * file = [[NSBundle mainBundle] pathForResource:@"facilityList" ofType:@"csv"];
    NSURL *url = [NSURL URLWithString:@"https://emdmoodle.transit.nyct.com/my/appScripts/facilityList.csv"];
    NSString * contents = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:nil];
    
    NSArray* rows = [contents componentsSeparatedByString:@"\n"];
    for (NSString *row in rows){
        NSArray* columns = [row componentsSeparatedByString:@","];
        if ([columns count]==2){
            [_facilities addObject: [columns objectAtIndex:1]];
        }
    }
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    
    _searchResults = [_facilities filteredArrayUsingPredicate:resultPredicate];
    
    
}

-(BOOL)searchDisplayController:(UISearchController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResults count];
        
    } else {
        return [_facilities count];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"facilityCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.table dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }else{
        cell = [self.table dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [_searchResults objectAtIndex:indexPath.row];
    }
    else {
        cell.textLabel.text = [_facilities objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Futura" size:20];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    CourseInfoViewController *courseRef = (CourseInfoViewController *)_courseInfo;
    UITableViewCell *cell =[tableView cellForRowAtIndexPath:[tableView indexPathForSelectedRow]];
    courseRef.facility= cell.textLabel.text;
    [self dismissViewControllerAnimated:YES completion:^(void){
        
    }];
}


- (IBAction)closeTable:(id)sender {
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


