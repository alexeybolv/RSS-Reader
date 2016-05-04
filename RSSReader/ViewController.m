//
//  ViewController.m
//  RSSReader
//
//  Created by Алексей on 04.05.16.
//  Copyright © 2016 Alexey. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RSSReader" withExtension:@"momd"];
    
    [[FeedRKObjectManager manager] configureWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    
    FeedRKObjectManager *feedManager = [FeedRKObjectManager manager];
    
    [feedManager addMappingForEntityForName:@"Feed" andAttributeMappingsFromDictionary:@{@"title.text" : @"feedTitle",@"link.text":@"feedLink",@"description.text":@"feedDescription",@"pubDate.text":@"feedDate",@"media:thumbnail.url":@"feedImageURL",} andIdentificationAttributes:@[@"feedTitle"] andKeyPath:@"rss.channel.item"];
    
    [feedManager getFeedObjectsAtPath:@"/feed" success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         
     }
                              failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         
     }];

    
    }


@end
