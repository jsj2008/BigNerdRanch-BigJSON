//
//  BNRGHReposViewController.m
//  BigJSON
//
//  Created by sam_smith5 on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BNRGHReposViewController.h"
#import "NSData+Base64.h"
#import "GHRepo.h"
#import "GHKeychainHelper.h"

static NSString *kLastAccessedUser = @"GitHubBrowserLastAccessedUser";

@interface BNRGHReposViewController ()
-(UIAlertView *)githubLoginAlert;
@end

@implementation BNRGHReposViewController
@synthesize tableView = _tableView, loginButton = _loginButton, repositories = _repositories;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Repositories";
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kLastAccessedUser])
    {
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kLastAccessedUser];
        BOOL found = NO;
        NSString *pw = [GHKeychainHelper passwordForAccount:username found:&found];
        
        if (found) {
            [_loginButton setTitle:@"Switch user" forState:UIControlStateNormal];
            [self loginWithUserName:username password:pw];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_repositories count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    GHRepo *repo = [_repositories objectAtIndex:indexPath.row];
    NSString *repoStr = [NSString stringWithFormat:@"%@", repo];
    [[cell textLabel] setText:repoStr];
    
    return cell;
}

-(UIAlertView *)githubLoginAlert
{
    return [[UIAlertView alloc] initWithTitle:@"GitHub Login" message:@"Please enter username and password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
}

-(IBAction)login:(id)sender
{
    UIAlertView *av = [self githubLoginAlert];
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    NSString *username = [[alertView textFieldAtIndex:0] text];
    NSString *password = [[alertView textFieldAtIndex:1] text];
    
    if ((username == nil) || (username.length == 0)) {
        UIAlertView *av = [self githubLoginAlert];
        [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        [av show];
        return;
    }
    
    NSLog(@"Username: %@ - Pasword: %@", username, password);
    [self loginWithUserName:username password:password];
}

-(void)loginWithUserName:(NSString *)un password:(NSString *)pw
{
    // Form URL and URL request to get list of user repositories
    NSURL *url = [NSURL URLWithString:@"https://api.github.com/user/repos"];
    NSMutableURLRequest *newReq = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // Add basic HTTP authentication to URL request
    // Get string "user:password", turn it into base64
    NSString *credentialsStr = [NSString stringWithFormat:@"%@:%@", un, pw];
    NSData *credentialData = [credentialsStr dataUsingEncoding:NSUTF8StringEncoding];
    
    // Add as header to request
    NSString *authStr = [@"Basic " stringByAppendingString:[credentialData base64EncodedString]];
    [newReq addValue:authStr forHTTPHeaderField:@"Authorization"];
    void (^handler)(NSURLResponse *urlResponse, NSData *responseData, NSError *error) = ^(NSURLResponse *urlResponse, NSData *responseData, NSError *error)
    {
        NSString *replyStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response: %@", replyStr);
        if (!error) {
            [[NSUserDefaults standardUserDefaults] setObject:un forKey:kLastAccessedUser];
            BOOL found = NO;
            [GHKeychainHelper passwordForAccount:un found:&found];
            
            if (found)
                [GHKeychainHelper updatePassword:pw forAccount:un];
            else
                [GHKeychainHelper setPassword:pw forAccount:un];
            
            _repositories = [GHRepo reposFromJSON:responseData];
            [_loginButton setTitle:@"Switch user" forState:UIControlStateNormal];
        } else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem logging in. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            _repositories = nil;
            [_loginButton setTitle:@"View my repos" forState:UIControlStateNormal];
        }
        [_tableView reloadData];
    };
    [NSURLConnection sendAsynchronousRequest:newReq queue:[NSOperationQueue currentQueue] completionHandler:handler];                                                                                                                 
}

@end
