//
//  MYEntry.h
//  MYFramework
//
//  Created by Whirlwind on 13-1-16.
//
//

#import <Foundation/Foundation.h>
//#import "NSObject+MYProperty.h"
#import "MYEntryDataAccessProtocol.h"

@interface MYEntry : NSObject{
    BOOL listening;
}

@property (strong, nonatomic) id dataAccessor;

@property (copy, nonatomic) NSString *userKey;

@property (strong, nonatomic) NSNumber *index;
@property (strong, nonatomic) NSNumber *remoteId;
@property (strong, nonatomic) MYDateTime *createdAt;
@property (strong, nonatomic) MYDateTime *updatedAt;

@property (strong, nonatomic) NSError *error;

@property (assign, nonatomic) BOOL needPostLocalChangeNotification;
@property (strong, nonatomic) NSMutableDictionary *changes;

- (id)initWithIndex:(NSNumber *)index;

#pragma mark - listen
- (void)listenProperty;
- (NSArray *)listenProperties;
- (void)disableListenProperty:(void(^)(void))block;
- (void)reverseWithProperty:(NSString *)property;
- (void)reverse;
- (void)postLocalChangeNotification;
+ (void)postLocalChangeNotification;

#pragma mark - DAO
- (BOOL)save;
- (BOOL)destroy;

#pragma mark - Convenient
+ (NSInteger)count;
+ (id)entryAt:(NSNumber *)index;
+ (BOOL)existEntry;

#pragma mark for override
- (BOOL)createEntry;
- (BOOL)updateEntry;
- (BOOL)removeEntry;

+ (NSString *)userKey;
+ (id)dataAccessor;
@end