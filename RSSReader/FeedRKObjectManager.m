//
//  FeedRKObjectManager.m
//  RSSReader
//
//  Created by Алексей on 04.05.16.
//  Copyright © 2016 Alexey. All rights reserved.
//

#import "FeedRKObjectManager.h"
#import "RKXMLReaderSerialization.h"

@implementation FeedRKObjectManager
{
    RKObjectManager *objectManager;
    RKManagedObjectStore *managedObjectStore;
}

#pragma mark - Configuring ManagedObjectStore

- (void) configureWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    if (!managedObjectModel)
    {
        return;
    }
    
    managedObjectStore = [[RKManagedObjectStore alloc]initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    
    if (!RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(),&error))
    {
        RKLogError(@"Failed to create Application Data Directory at path: '%@':'%@'",RKApplicationDataDirectory(), error);
    }
    
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"RKFeed.sqlite"];
    if (![managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error])
    {
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    }
    
    [managedObjectStore createManagedObjectContexts];
    objectManager.managedObjectStore = managedObjectStore;
}

#pragma mark - Mapping

- (void) addMappingForEntityForName:(NSString *)entityName
 andAttributeMappingsFromDictionary:(NSDictionary *)attributeMappings
        andIdentificationAttributes:(NSArray *)ids
                         andKeyPath:(NSString *)keyPath
{
    if (!managedObjectStore)
    {
        return;
    }
    
    RKEntityMapping *objectMapping = [RKEntityMapping mappingForEntityForName:entityName inManagedObjectStore:managedObjectStore];
    
    [objectMapping addAttributeMappingsFromDictionary:attributeMappings];
    
    objectMapping.identificationAttributes = ids;
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:objectMapping method:RKRequestMethodGET pathPattern:nil keyPath:keyPath statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

#pragma mark - Getting Objects

- (void) getFeedObjectsAtPath:(NSString *)path
                  success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success
                  failure:(void (^)(RKObjectRequestOperation *, NSError *))failure
{
    [objectManager getObjectsAtPath:path parameters:nil success:success failure:failure];
}

#pragma mark - Singleton Accessor

+ (FeedRKObjectManager *)manager
{
    static FeedRKObjectManager *manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[FeedRKObjectManager alloc] init];
    });
    return manager;
}


- (id) init{
    
    self = [super init];
    if (self)
    {
        NSURL *baseURL = [NSURL URLWithString:@"https://auto.onliner.by"];
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        objectManager = [[RKObjectManager alloc]initWithHTTPClient:client];
        [objectManager setRequestSerializationMIMEType:RKMIMETypeTextXML];
        [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"text/xml"];
    }
    
    return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return managedObjectStore.mainQueueManagedObjectContext;
}



@end
