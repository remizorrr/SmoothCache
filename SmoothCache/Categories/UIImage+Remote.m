//
//  UIImage+Remote.m
//  Vacarious
//
//  Created by Anton Remizov on 12/16/15.
//  Copyright © 2015 Appcoming. All rights reserved.
//

#import "UIImage+Remote.h"
#import <AFNetworking/AFNetworking.h>
#import "SCCache.h"

@implementation UIImage (Remote)

+ (void) imageForPath:(NSString*)path withCompletion:(void(^)(UIImage* image, NSString* cache)) completion {
    [[SCCache defaultCache] objectForKey:path completion:^(id object, NSString* cache) {
        if (object) {
            if (completion) {
                completion(object, cache);
            }
            return;
        }
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completion) {
                completion(responseObject, nil);
            }
            [[SCCache defaultCache] cacheObject:responseObject forKey:path completion:nil];
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            if (completion) {
                completion(nil, nil);
            }
        }];
        [requestOperation start];
    }];
}

@end
