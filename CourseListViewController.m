//
//  CourseListViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/15/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "CourseListViewController.h"
#import "CourseListTableViewCell.h"


@interface CourseListViewController ()
@property NSMutableArray *courses;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;
@property NSArray *searchResults;
@end

@implementation CourseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _courses = [[NSMutableArray alloc] init];
    _table.delegate=self;
    _table.dataSource=self;
    _table.rowHeight=70;
    [self dbQuery];

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



- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF.course contains[cd] %@ || SELF.code contains[cd] %@",
                                    searchText, searchText];
    
    _searchResults = [_courses filteredArrayUsingPredicate:resultPredicate];
    
    
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
        return [_courses count];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"courseCell";
    
    CourseListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.table dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }else{
        cell = [self.table dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    }
    
    if (cell == nil) {
        cell = [[CourseListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        tableView.rowHeight=70;
        cell.codeLabel.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"code"];
        cell.courseLabel.text = [[_searchResults objectAtIndex:indexPath.row] objectForKey:@"course"];
    } else {
        cell.codeLabel.text = [[_courses objectAtIndex:indexPath.row] objectForKey: @"code"];
        cell.courseLabel.text = [[_courses objectAtIndex:indexPath.row] objectForKey: @"course"];
    }
    
    cell.codeLabel.font = [UIFont fontWithName:@"Futura" size:12];
    cell.courseLabel.font = [UIFont fontWithName:@"Futura" size:20];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    CourseInfoViewController *courseRef = (CourseInfoViewController *)_courseInfo;
    CourseListTableViewCell *cell =[tableView cellForRowAtIndexPath:[tableView indexPathForSelectedRow]];
    courseRef.course= cell.courseLabel.text;
    [self dismissViewControllerAnimated:YES completion:^(void){
        
    }];
}


- (IBAction)closeTable:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dbQuery
{
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://emdmoodle.transit.nyct.com/my/appScripts/courseList.php"]];
    
    NSString *userUpdate = @"code=EMD21A005";
    
    //create the Method "GET" or "POST"
    [urlRequest setHTTPMethod:@"POST"];
    
    //Convert the String to Data
    NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
    
    //Apply the data to the body
    [urlRequest setHTTPBody:data1];
    
    __block NSString *responseString;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200)
        {
            id courseList = [NSJSONSerialization
                         JSONObjectWithData:data
                         options:0
                         error:&error];
            responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(courseList)
            {
                for (id entry in courseList){
                    NSData *objectData = [entry dataUsingEncoding:NSUTF8StringEncoding];
                    id dataset = [NSJSONSerialization
                                     JSONObjectWithData:objectData
                                     options:0
                                     error:&error];

                    [_courses addObject:dataset];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_table reloadData];
                });

            }
            else
            {
                
            }
        }
        else
        {
            
        }
    }];
    [dataTask resume];
    
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
