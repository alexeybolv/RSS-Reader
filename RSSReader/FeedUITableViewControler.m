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

@interface FeedUITableViewControler ()

@property (strong, nonatomic) IBOutlet UITableView *feedTableView;
@property (strong,nonatomic) NSArray *feedArray;

@end

@implementation FeedUITableViewControler

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 200;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RSSReader" withExtension:@"momd"];
    
    [[FeedRKObjectManager manager] configureWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    
    [[FeedRKObjectManager manager] addMappingForEntityForName:@"Feed" andAttributeMappingsFromDictionary:@{@"title.text" : @"feedTitle",@"link.text":@"feedLink",@"description.text":@"feedDescription",@"pubDate.text":@"feedDateString",@"media:thumbnail.url":@"feedImageURL",} andIdentificationAttributes:@[@"feedTitle"] andKeyPath:@"rss.channel.item"];
    [self loadFeeds];
}

- (void) saveToStore{
    NSError *saveError;
    if (![[[FeedRKObjectManager manager] managedObjectContext] saveToPersistentStore:&saveError])
    {
        NSLog(@"%@", [saveError localizedDescription]);
    }
}

- (void) loadFeeds{
    
    //Creating activity indicator
    UIActivityIndicatorView *activityIndicator= [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    activityIndicator.layer.cornerRadius = 05;
    activityIndicator.opaque = NO;
    activityIndicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    activityIndicator.center = self.view.center;
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicator setColor:[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]];
    [self.view addSubview: activityIndicator];
    
    //switch to background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityIndicator startAnimating];
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
                                                        [self fetchFeedsFromContext];
                                                    }
                                                    failure:^(RKObjectRequestOperation *operation, NSError *error){
                                                        NSLog(@"Error': %@", error);
                                                        [self fetchFeedsFromContext];
                                                    }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityIndicator stopAnimating];
        });
    });

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

- (void)loadThumbnailFromURLString:(NSString *)urlString forFeed:(Feed *)feed {
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        feed.feedImageData = responseObject;
        [self saveToStore];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    [operation start];
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
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"CustomViewCell" bundle:nil] forCellReuseIdentifier:@"CustomCellIdentifier"];
        cell = (FeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CustomCellIdentifier"];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(FeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *item = [_feedArray objectAtIndex:indexPath.row];
    [cell setInternalFields:item];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"ShowDetailIdentifier" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue destinationViewController];
    // Pass the selected object to the new view controller.
}


//-(NSString *) newDescriptionbyStrippingHTMLFromString:(NSString *)myStr
//{
//    NSRange r;
//    while ((r = [myStr rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
//        myStr = [myStr stringByReplacingCharactersInRange:r withString:@""];
//    return myStr;
//}


@end
