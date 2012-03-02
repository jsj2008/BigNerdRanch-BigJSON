//
//  BNRFirstViewController.m
//  BigJSON
//
//  Created by sam_smith5 on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BNRGHEventsViewController.h"
#import "GHEvent.h"

@interface BNRGHEventsViewController ()
@property(nonatomic, strong) NSArray *ghEvents;
@property(nonatomic, strong) UILabel *statusLabel;

@property(nonatomic, strong) NSIndexPath *selectedIndexPath;
@property(nonatomic, strong) NSIndexPath *actionRowIndexPath;

-(void)refreshEventsAndRun:(dispatch_block_t)handler;
@end

@implementation BNRGHEventsViewController
@synthesize ghEvents = _ghEvents, eventTable = _eventTable, statusLabel = _statusLabel;
@synthesize selectedIndexPath = _selectedIndexPath, actionRowIndexPath = _actionRowIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Events";
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"gh_events" ofType:@"js"];
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
        _ghEvents = [GHEvent eventsFromJSON:jsonData];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [_eventTable setDataSource:self];
    [(UIScrollView *)_eventTable setDelegate:self];
    // Create the secret view
    CGRect labelRect = CGRectMake(_eventTable.bounds.origin.x,
                                  _eventTable.bounds.origin.y - 30.f,
                                  _eventTable.bounds.size.width, 20.0f);
    self.statusLabel = [[UILabel alloc] initWithFrame:labelRect];
    self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.statusLabel.font = [UIFont boldSystemFontOfSize:24];
    self.statusLabel.textColor = [UIColor blackColor];
    self.statusLabel.textAlignment = UITextAlignmentCenter;
    self.statusLabel.text = @"Peek-a-boo!";
    [_eventTable addSubview:self.statusLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self refreshEventsAndRun:^(){}];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)refreshEventsAndRun:(dispatch_block_t)finishRefreshHandler
{
    // Github API
    NSString *ghEventsAPIURL = @"https://api.github.com/events";
    NSURL *url = [[NSURL alloc] initWithString:ghEventsAPIURL];
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
        _ghEvents = [GHEvent eventsFromJSON:responseData];
        [_eventTable reloadData];
        finishRefreshHandler();
        NSLog(@"Reloaded");
    };
    [NSURLConnection sendAsynchronousRequest:newReq queue:[NSOperationQueue mainQueue] completionHandler:handler];
}

-(NSIndexPath *)modelIndexPath:(NSIndexPath *)indexPath
{
    if (self.actionRowIndexPath == nil) {
        return indexPath;
    }
    
    if ([indexPath row] > [self.actionRowIndexPath row]) {
        return [NSIndexPath indexPathForRow:([indexPath row] - 1) inSection:indexPath.section];
    }
    
    return indexPath;
}

#pragma mark - Table View

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.actionRowIndexPath) {
        return [_ghEvents count] + 1;
    } else {
        return [_ghEvents count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MyCell";
    UITableViewCell *cell;
    /*
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        UIImageView *avatarView = cell.imageView;
        avatarView.image = [UIImage imageNamed:@"empty_avatar.png"];
    }*/
    
    GHEvent *event = [_ghEvents objectAtIndex:[indexPath row]];
    if ([indexPath isEqual:self.actionRowIndexPath]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActionCell"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"View User" forState:UIControlStateNormal];
        [button setFrame:CGRectMake(10.0f, 3.0f, 160.0f, 40.0f)];
        [button addTarget:self action:@selector(openEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        indexPath = [self modelIndexPath:indexPath];
        cell.textLabel.text = [event description];
    }
    
    /*
    if (event.avatar_url) {
        NSLog(@"avatar_url: %@", event.avatar_url);
        NSURL *url = [[NSURL alloc] initWithString:event.avatar_url];
        NSURLRequest *avatarReq = [[NSURLRequest alloc] initWithURL:url];
        [NSURLConnection sendAsynchronousRequest:avatarReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *urlResponse, NSData *responseData, NSError *error) 
        {
            event.avatar_image = [UIImage imageWithData:responseData];
            
        }
    } else {
        
    }*/
    
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableview willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.actionRowIndexPath]) {
        return self.selectedIndexPath;
    }
    
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // We will remove the current action row, store it before it changes
    NSIndexPath *pathToDelete = self.actionRowIndexPath;
    
    // Convert to action row-less path
    indexPath = [self modelIndexPath:indexPath];
    
    // Is user deselecting current action row?
    if ([indexPath isEqual:self.selectedIndexPath]) {
        [_eventTable deselectRowAtIndexPath:self.selectedIndexPath animated:NO];
    }
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        self.actionRowIndexPath = nil;
        self.selectedIndexPath = nil;
    } else {
        self.selectedIndexPath = indexPath;
        self.actionRowIndexPath = [NSIndexPath indexPathForRow:([indexPath row] + 1) inSection:indexPath.section];
    }
    
    [_eventTable beginUpdates];
    if (pathToDelete) {
        [_eventTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathToDelete] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if (self.actionRowIndexPath) {
        [_eventTable insertRowsAtIndexPaths:[NSArray arrayWithObject:self.actionRowIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }  
    [_eventTable endUpdates];
}

-(void)openEvent:(id)sender
{
    NSAssert(self.selectedIndexPath != nil, @"%@ called with no selection", _cmd);
    
    // Get the URL for the user
    GHEvent *selectedEvent = [_ghEvents objectAtIndex:[self.selectedIndexPath row]];
    NSString *urlStr = [@"http://github.com/" stringByAppendingString:selectedEvent.username];
    
    NSURL *userURL = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:userURL];
}

#pragma mark - Scroll View

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= -40.0) {
        self.statusLabel.text = @"Found me!";
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    const float max_offset = 40.0f;
    if (scrollView.contentOffset.y <= -max_offset) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(40.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
        
        dispatch_block_t refreshDoneBlock = ^{
               [UIView beginAnimations:nil context:NULL];
               [UIView setAnimationDuration:0.2];
               scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
               [UIView commitAnimations];
                self.statusLabel.text = @"Peek-a-boo!";
        };
        [self refreshEventsAndRun:refreshDoneBlock];
    }
}

@end
