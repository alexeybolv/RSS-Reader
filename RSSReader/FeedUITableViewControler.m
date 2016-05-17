//
//  FeedUITableViewControler.m
//  RSSReader
//
//  Created by Алексей on 04.05.16.
//  Copyright © 2016 Alexey. All rights reserved.
//

#import "FeedUITableViewControler.h"
#import "FeedTableViewCell.h"
#import "FeedRKObjectManager.h"
#import "Feed.h"
#import "FeedDetailViewController.h"
#import "Reachability.h"

@interface FeedUITableViewControler ()

@property (strong, nonatomic) IBOutlet UITableView *feedTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (strong,nonatomic) NSArray *feedArray;
@property (nonatomic) Reachability *internetReachability;
@property (strong,nonatomic) NSMutableArray *indexArray;
@property (strong,nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation FeedUITableViewControler

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onliner_logo.png"]];
    
    // setting up Mapping and Loading
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RSSReader" withExtension:@"momd"];
    
    [[FeedRKObjectManager manager] configureWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    
    [[FeedRKObjectManager manager] addMappingForEntityForName:@"Feed" andAttributeMappingsFromDictionary:@{@"title.text" : @"feedTitle",@"link.text":@"feedLink",@"description.text":@"feedDescription",@"pubDate.text":@"feedDateString",@"media:thumbnail.url":@"feedImageURL",} andIdentificationAttributes:@[@"feedTitle"] andKeyPath:@"rss.channel.item"];
    [self loadFeeds];
    
    // setting up Reachability
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self checkReachability:self.internetReachability];
}

- (void) viewWillAppear:(BOOL)animated
{
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        self.tableView.rowHeight = 200;
    }
    else if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        self.tableView.rowHeight = 345;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark - Parsing Feed

- (IBAction)refreshButton:(id)sender {
    [self checkReachability:self.internetReachability];
    [self loadFeeds];
}


- (void) loadFeeds{
    
    //Creating activity indicator
    self.activityIndicator= [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.activityIndicator.layer.cornerRadius = 05;
    self.activityIndicator.opaque = NO;
    self.activityIndicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    self.activityIndicator.center = self.feedTableView.center;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.activityIndicator setColor:[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]];
    [self.view addSubview: self.activityIndicator];
    
    //switch to background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator startAnimating];
            self.refreshButton.enabled = false;
        });
        
        [[FeedRKObjectManager manager] getFeedObjectsAtPath:@"/feed"
                                                    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
                                                        
                                                        NSArray *requestArray = mappingResult.array;
                                                        
                                                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                                        [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
                                                        
                                                        for (Feed *item in requestArray)
                                                        {
                                                            NSDate *date = [dateFormat dateFromString:item.feedDateString];
                                                            item.feedDate = date;
                                                            [self loadThumbnailFromURLString:item.feedImageURL forFeed:item];
                                                            [self saveToStore];
                                                        }
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self.activityIndicator stopAnimating];
                                                            self.refreshButton.enabled = true;
                                                        });
                                                    }
                                                    failure:^(RKObjectRequestOperation *operation, NSError *error){
                                                        NSLog(@"Error': %@", error);
                                                        [self fetchFeedsFromContext];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self.activityIndicator stopAnimating];
                                                            self.refreshButton.enabled = true;
                                                        });
                                                    }];
    });
}


- (void)loadThumbnailFromURLString:(NSString *)urlString forFeed:(Feed *)feed {
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        feed.feedImageData = responseObject;
        [self fetchFeedsFromContext];
        [self.tableView reloadData];
        [self saveToStore];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    [operation start];
}

#pragma mark - Core Data

- (void) saveToStore{
    NSError *saveError;
    if (![[[FeedRKObjectManager manager] managedObjectContext] saveToPersistentStore:&saveError])
    {
        NSLog(@"%@", [saveError localizedDescription]);
    }
}

- (void) fetchFeedsFromContext{
    NSManagedObjectContext *context = [[FeedRKObjectManager manager] managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"feedDate" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    
    NSError *error;
    _feedArray = [context executeFetchRequest:fetchRequest error:&error];
    [self.feedTableView reloadData];
}



#pragma mark - Reachability

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    [self checkReachability:curReach];
}

-(void) checkReachability:(Reachability *)reachability{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    if (netStatus == NotReachable)
    {
        UIAlertController *internetConnectionController = [UIAlertController alertControllerWithTitle:@"Problem" message:@"Please, switch on the Internet to parse latest news and press refresh" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:internetConnectionController animated:YES completion:nil];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self checkReachability:self.internetReachability];
            [self loadFeeds];
        }];
        
        [internetConnectionController addAction:settingsAction];
        [internetConnectionController addAction:retryAction];
        [internetConnectionController addAction:cancelAction];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _feedArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FeedTableViewCell *cell = (FeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CustomCellIdentifier"];
    
    if (!cell) {
        if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
        {
            [tableView registerNib:[UINib nibWithNibName:@"CustomViewCell-Portrait" bundle:nil] forCellReuseIdentifier:@"CustomCellIdentifier"];
            [self.indexArray addObject:indexPath];
        }
        else if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        {
            [tableView registerNib:[UINib nibWithNibName:@"CustomViewCell-Landscape" bundle:nil] forCellReuseIdentifier:@"CustomCellIdentifier"];
            [self.indexArray addObject:indexPath];
        }
    }
    cell = (FeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CustomCellIdentifier"];
    return cell;
}



- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        self.tableView.rowHeight = 200;
        [self.feedTableView registerNib:[UINib nibWithNibName:@"CustomViewCell-Portrait" bundle:nil] forCellReuseIdentifier:@"CustomCellIdentifier"];
    }
    else
    {
        self.tableView.rowHeight = 345;
        [self.feedTableView registerNib:[UINib nibWithNibName:@"CustomViewCell-Landscape" bundle:nil] forCellReuseIdentifier:@"CustomCellIdentifier"];
    }
    self.activityIndicator.center = self.feedTableView.center;
    
    [self.tableView reloadRowsAtIndexPaths:[self indexPathsForTableView:self.feedTableView] withRowAnimation:UITableViewRowAnimationRight];
    [self.feedTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
}

- (NSMutableArray *) indexPathsForTableView:(UITableView *)tableView{
    NSMutableArray *indexArray = [[NSMutableArray alloc]init];
    for (int i = 0;i<self.feedArray.count;i++)
    {
        [indexArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    return indexArray;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(FeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *item = [_feedArray objectAtIndex:indexPath.row];
    [cell setInternalFields:item];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"ShowDetailIdentifier" sender:[tableView cellForRowAtIndexPath:indexPath]];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FeedDetailViewController *child = (FeedDetailViewController *)[segue destinationViewController];
    Feed *item;
    FeedTableViewCell *source = (FeedTableViewCell *)sender;
    item = source.localFeedEntity;
    [child receiveFeedEntity:item];
}


@end
