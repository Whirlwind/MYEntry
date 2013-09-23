//
//  MYEntry.m
//  Pods
//
//  Created by Whirlwind on 13-1-16.
//
//

#import "MYEntry.h"

@implementation MYEntry

- (void)dealloc {
    if (listening) {
        [[self listenProperties] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self removeObserver:self forKeyPath:obj];
        }];
    }
}

- (NSNumber *)index {
    if (_index == nil) {
        return self.remoteId;
    }
    return _index;
}

- (void)setCreatedAt:(MYDateTime *)createdAt {
    if ([createdAt isKindOfClass:[MYDateTime class]]) {
        _createdAt = createdAt;
    } else {
        _createdAt = [MYDateTime dateWithObject:createdAt];
    }
}

- (void)setUpdatedAt:(MYDateTime *)updatedAt {
    _updatedAt = nil;
    if ([updatedAt isKindOfClass:[MYDateTime class]]) {
        _updatedAt = updatedAt;
    } else {
        _updatedAt = [MYDateTime dateWithObject:updatedAt];
    }
}

- (id)init {
    if (self = [super init]) {
        listening = NO;
        self.needPostLocalChangeNotification = YES;
    }
    return self;
}

- (id)initWithIndex:(NSNumber *)index {
    if (self = [self init]) {
        self.index = index;
    }
    return self;
}

- (void)disableListenProperty:(void(^)(void))block {
    BOOL old = listening;
    listening = NO;
    block();
    listening = old;
}

#pragma mark - getter

- (id)dataAccessor {
    if (_dataAccessor == nil) {
        _dataAccessor = [[self class] dataAccessor];
        [_dataAccessor setEntry:self];
    }
    return _dataAccessor;
}

- (NSMutableDictionary *)changes {
    if (_changes == nil)
        _changes = [[NSMutableDictionary alloc] initWithCapacity:0];
    return _changes;
}

- (void)postLocalChangeNotification {
    if (self.needPostLocalChangeNotification) {
        [[self class] postLocalChangeNotification];
    }
}

+ (void)postLocalChangeNotification {
    MY_BACKGROUND_BEGIN
    POST_BROADCAST;
    MY_BACKGROUND_COMMIT
}

- (NSString *)userKey {
    if (_userKey != nil) {
        return _userKey;
    }
    return [[self class] userKey];
}

+ (NSString *)userKey {
    return @" ";
}

#pragma mark - listener
- (NSArray *)listenProperties {
    if ([self.dataAccessor respondsToSelector:@selector(dataProperties)]) {
        return [self.dataAccessor dataProperties];
    }
    return @[];
}
- (void)listenProperty {
    listening = YES;
    [[self listenProperties] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addObserver:self
               forKeyPath:obj
                  options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                  context:nil];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!listening) {
        return;
    }
    if ([keyPath isEqualToString:@"index"])
        return;
    id oldValue = [change valueForKey:NSKeyValueChangeOldKey];
    id newValue = [change valueForKey:NSKeyValueChangeNewKey];
    if ([oldValue isEqual:newValue])
        return;
    if (oldValue == nil) {
        oldValue = [NSNull null];
    }
    NSMutableArray *array = [self.changes valueForKey:keyPath];
    if (array == nil) {
        array = [NSMutableArray arrayWithObjects:oldValue, newValue,  nil];
        (self.changes)[keyPath] = array;
    } else {
        if ([array[0] isEqual:newValue]) {
            [self.changes removeObjectForKey:keyPath];
        } else {
            array[1] = newValue;
        }
    }
}


#pragma mark - reverse
- (void)reverseWithProperty:(NSString *)property {
    SEL selector = [[self class] setterFromPropertyString:property];
    NSArray *change = (NSArray *)[self.changes valueForKey:property];
    if (change == nil)
        return;
    MYPerformSelectorWithoutLeakWarningBegin
    [self performSelector:selector withObject:change[0]];
    MYPerformSelectorWithoutLeakWarningEnd
}

- (void)reverse {
    for (NSString *property in self.changes.allKeys) {
        [self reverseWithProperty:property];
    }
}

#pragma mark - DAO
- (BOOL)save {
    if (self.index != nil && [_changes count] <= 0) {
        return YES;
    }
    [self setUpdatedAt:(MYDateTime *)[NSDate date]];
    BOOL status = NO;
    if (_index == nil) { // C
        status = [self createEntry];
    } else { // U
        status = [self updateEntry];
    }
    if (status) {
        [self postLocalChangeNotification];
        [self.changes removeAllObjects];
    }
    return status;
}

- (BOOL)destroy {
    [self setUpdatedAt:(MYDateTime *)[NSDate date]];
    return [self removeEntry];
}

#pragma mark - Convenient
+ (NSInteger)count {
    return [[self dataAccessor] countEntries];
}
+ (id)entryAt:(NSNumber *)index {
    return [[self dataAccessor] entryAt:index];
}
+ (BOOL)existEntry {
    return [[self dataAccessor] existEntry];
}
+ (MYEntry *)firstEntry {
    NSObject<MYEntryDataAccessProtocol> *accessor = [self dataAccessor];
    if ([accessor respondsToSelector:@selector(firstEntry)]) {
        return [[self dataAccessor] firstEntry];
    }
    LogError(@"[%@ %@] NOT implement!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return nil;
}
#pragma mark for override
- (BOOL)createEntry {
    return [self.dataAccessor createEntry];
}

- (BOOL)updateEntry {
    return [self.dataAccessor updateEntry];
}

- (BOOL)removeEntry {
    return [self.dataAccessor removeEntry];
}

+ (id)dataAccessor {
    return nil;
}
@end
