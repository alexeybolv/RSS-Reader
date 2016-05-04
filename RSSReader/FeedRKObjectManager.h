//
//  FeedRKObjectManager.h
//  RSSReader
//
//  Created by Алексей on 04.05.16.
//  Copyright © 2016 Alexey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface FeedRKObjectManager : NSObject

+ (FeedRKObjectManager *)manager;

- (NSManagedObjectContext *)managedObjectContext;

- (void) configureWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;

- (void) addMappingForEntityForName:(NSString *)entityName
 andAttributeMappingsFromDictionary:(NSDictionary *)attributeMappings
        andIdentificationAttributes:(NSArray *)ids
                         andKeyPath:(NSString *)keyPath;

- (void) getFeedObjectsAtPath:(NSString *)path
                      success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success
                      failure:(void (^)(RKObjectRequestOperation *, NSError *))failure;


@end
