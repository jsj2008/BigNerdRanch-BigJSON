//
//  BNRSecondViewController.m
//  BigJSON
//
//  Created by sam_smith5 on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BNRCommitsViewController.h"
#import "GHCommit.h"

@interface BNRCommitsViewController ()
@property(nonatomic, strong) NSArray *ghCommits;
-(void)refreshCommits;
@end

@implementation BNRCommitsViewController
@synthesize ghCommits = _ghCommits, commitTable = _commitTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Commits";
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"gh_commits" ofType:@"js"];
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
        _ghCommits = [GHCommit commitsFromJSON:jsonData];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [_commitTable setDataSource:self];
    [self refreshCommits];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)refreshCommits
{
    // Github API
    NSString *ghCommitsAPIURL = @"https://api.github.com/repos/joyent/node/commits";
    NSURL *url = [[NSURL alloc] initWithString:ghCommitsAPIURL];
    NSURLRequest *newReq = [[NSURLRequest alloc] initWithURL:url];
    
    NSLog(@"Initiating refresh...");
    
    void (^handler)(NSURLResponse *urlResponse, NSData *responseData, NSError *error) = 
    ^(NSURLResponse *urlResponse, NSData *responseData, NSError *error)
    {
        if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            NSDictionary *headers = [(NSHTTPURLResponse *)urlResponse allHeaderFields];
            NSString *rateLimit = [headers objectForKey:@"X-RateLimit-Limit"];
            NSString *callsLeft = [headers objectForKey:@"X-RateLimit-Remaining"];
            NSLog(@"%@ of %@ calls remaining", callsLeft, rateLimit);
        }
        _ghCommits = [GHCommit commitsFromJSON:responseData];
        [_commitTable reloadData];
        NSLog(@"Reloaded");
    };
    [NSURLConnection sendAsynchronousRequest:newReq queue:[NSOperationQueue mainQueue] completionHandler:handler];
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_ghCommits count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[_ghCommits objectAtIndex:[indexPath row]] summaryDescription];
    cell.detailTextLabel.text = [[_ghCommits objectAtIndex:[indexPath row]] detailDescription];
    
    return cell;
}

@end
