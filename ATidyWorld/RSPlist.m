//
//  RSPlist.m
//  A Tidy World
//
//  Created by Rudi Strahl on 12-02-01.
//  Copyright (c) 2012 Rudi Strahl. All rights reserved.
//

#import "RSPlist.h"

@implementation RSPlist

+ (NSString *)createPathForPList:(NSString *)fileName
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:
                                        [NSString stringWithFormat:@"%@.plist", fileName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
        
        if (![fileManager copyItemAtPath:bundle toPath:path error:&error])
        {
            NSLog(@"ERROR writing Plist: %@", [error localizedDescription]);
        }
    }
    return path;
}

+ (NSData *)readPlist:(NSString *)fileName
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) 
    {
        plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    }
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSData *plist = [NSPropertyListSerialization
                                          propertyListFromData:plistData
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
    if (!plist) 
    {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    else
    {
        NSLog(@"Read plist: %@", plist);
    }
    return plist;  
}  

+ (void)writePlist:(id)plist fileName:(NSString *)fileName
{  
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plist
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) 
    {
        if (![plistData writeToFile:plistPath atomically:YES])
        {
            NSLog(@"Failed writing plist:%@, path: %@", fileName, plistPath);
        }
    }
    else
    {
        NSLog(@"Error writing plist: %@, error: %@", fileName, error);
    }
}  

@end
