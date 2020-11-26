//
//  TJZipCompress.h
//
//  Created by Tim Johnsen on 11/25/20.
//  Copyright © 2020 Tim Johnsen. All rights reserved.
//

FOUNDATION_EXTERN void TJZipCompress(NSURL *const fromFileURL, NSURL *const toFileURL)
{
    // https://twitter.com/steipete/status/1331670439471554560
    // https://stackoverflow.com/questions/1928162/creating-a-zip-archive-from-a-cocoa-application
    NSFileManager *const fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    NSURL *urlToZip;
    NSURL *urlToCleanUp;
    if ([fileManager fileExistsAtPath:fromFileURL.path isDirectory:&isDirectory]) {
        if (isDirectory) {
            urlToZip = fromFileURL;
            urlToCleanUp = nil;
        } else {
            // Only directories can be zipped.
            // Copy the file in question to a temporary directory to zip it.
            // [sandbox]/Library/Caches/[a UUID]/Archive/[filename of zipped file]
            urlToCleanUp = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]] isDirectory:YES];
            urlToZip = [urlToCleanUp URLByAppendingPathComponent:@"Archive"];
            [fileManager createDirectoryAtURL:urlToZip
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:nil];
            if (![fileManager copyItemAtURL:fromFileURL
                                      toURL:[urlToZip URLByAppendingPathComponent:fromFileURL.lastPathComponent]
                                      error:nil]) {
                urlToZip = nil;
            }
        }
    } else {
        urlToZip = nil;
        urlToCleanUp = nil;
    }
    if (urlToZip) {
        [[NSFileCoordinator new] coordinateReadingItemAtURL:urlToZip
                                                    options:NSFileCoordinatorReadingForUploading
                                                      error:nil
                                                 byAccessor:^(NSURL * _Nonnull newURL) {
            [[NSFileManager defaultManager] copyItemAtURL:newURL
                                                    toURL:toFileURL
                                                    error:nil];
        }];
    }
    if (urlToCleanUp) {
        [fileManager removeItemAtURL:urlToCleanUp
                        error:nil];
    }
}
