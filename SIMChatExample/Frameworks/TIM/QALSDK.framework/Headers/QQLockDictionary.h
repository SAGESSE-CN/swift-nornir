//
//  QQLockDictionary.h
//  QQMSFContact
//
//  Created by Yang Jin on 12-9-8.
//
//
#ifndef QQLOCK_DICTIONARY_H
#define QQLOCK_DICTIONARY_H
#import <Foundation/Foundation.h>

@interface QQLockDictionary : NSObject {
    NSLock* _lock;
    NSMutableDictionary* _dict;
}
- (id)initWithMutableDictionary:(NSMutableDictionary*)dic;
- (id)objectForKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;
- (void)setValue:(id)value forKey:(NSString *)key;
- (id)valueForKey:(NSString *)key;
- (NSArray*)allKeys;
- (NSArray*)allValues;
- (NSArray*)allKeysForObject:(id)object;
- (void)removeAllObjects;
- (void)removeObjectsForKeys:(NSArray*)keys;
- (int)count;
- (void)setDictionary:(NSMutableDictionary*)dic;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;

+ (QQLockDictionary*)dictionaryWithMutableDictionary:(NSMutableDictionary*)dic;

@end
#endif