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
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RSSReader" withExtension:@"momd"];
    
    [[FeedRKObjectManager manager] configureWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    
    [[FeedRKObjectManager manager] addMappingForEntityForName:@"Feed" andAttributeMappingsFromDictionary:@{@"title.text" : @"feedTitle",@"link.text":@"feedLink",@"description.text":@"feedDescription",@"pubDate.text":@"feedDate",@"media:thumbnail.url":@"feedImageURL",} andIdentificationAttributes:@[@"feedTitle"] andKeyPath:@"rss.channel.item"];
    //[self loadFeeds];
    [self fetchFeedsFromContext];
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
                                                    }
                                                    failure:^(RKObjectRequestOperation *operation, NSError *error){
                                                    }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityIndicator stopAnimating];
        });
    });

}

- (void) fetchFeedsFromContext{
    NSManagedObjectContext *context = [[FeedRKObjectManager manager] managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
    
    NSError *error;
    _feedArray = [context executeFetchRequest:fetchRequest error:&error];
    [self.feedTableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _feedArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Feed *item = [_feedArray objectAtIndex:indexPath.row];
    FeedTableViewCell *cell = (FeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TableCellIdentifier" forIndexPath:indexPath];
    [cell setInternalFields:item];
    return cell;
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
