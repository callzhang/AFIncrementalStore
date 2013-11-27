// CheckInsAPIClient.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CheckInsAPIClient.h"

static NSString * const kAFIncrementalStoreExampleAPIBaseURLString = @"https://api.parse.com/1/";

@implementation CheckInsAPIClient

+ (CheckInsAPIClient *)sharedClient {
    static CheckInsAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAFIncrementalStoreExampleAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.parameterEncoding = AFJSONParameterEncoding;
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Content-Type" value:@"application/json"];
    [self setDefaultHeader:@"X-Parse-Application-Id" value:@"FWleLi5CkEfziHZTb2RlZ1RFgZVEa7cdsjt4HpLT"];
    [self setDefaultHeader:@"X-Parse-REST-API-Key" value:@"2jAwSuO0tmh3cFA3jNaYXV4KSJnKUc9JJpMA9m7y"];
    
    //[self setAuthorizationHeaderWithUsername:@"aISrB65XT4oj46hvQywSx4YnYtf9DZZLEojLsAaX"
    //                                password:@"SpEldL5yLzysNZoZAQJkZZS3dwJSolzYzemKuzZ5"];
    
    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        self.operationQueue.suspended = (status == AFNetworkReachabilityStatusNotReachable);
    }];
    
    return self;
}

- (NSString *)pathForEntity:(NSEntityDescription *)entity{
    NSString *className = entity.name;
    NSString *path = [NSString stringWithFormat:@"classes/%@", className];
    return path;
}

- (NSString *)pathForObject:(NSManagedObject *)object{
    NSString *resourceIdentifier = AFResourceIdentifierFromReferenceObject([(NSIncrementalStore *)object.objectID.persistentStore referenceObjectForObjectID:object.objectID]);
    NSString *path = [[self pathForEntity:object.entity] stringByAppendingPathComponent:[resourceIdentifier lastPathComponent]];
    return path;
}


#pragma -
- (id)representationOrArrayOfRepresentationsOfEntity:(NSEntityDescription *)entity
                                  fromResponseObject:(id)responseObject{

    if ([responseObject isKindOfClass:[NSArray class]]) {
        return responseObject;
    } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
        if (!responseObject[@"results"]) {
            return nil;
        }
        NSDictionary *responseDict = responseObject[@"results"];
        NSMutableArray *arrayOfRepresentation = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in responseDict) {
            arrayOfRepresentation[arrayOfRepresentation.count] = dict;
        }
        
        return arrayOfRepresentation;
    }

    return nil;
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
                                     ofEntity:(NSEntityDescription *)entity
                                 fromResponse:(NSHTTPURLResponse *)response
{
    NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
    if ([entity.name isEqualToString:@"CheckIn"]) {
        
    }
    
    return mutablePropertyValues;
}

- (NSString *)resourceIdentifierForRepresentation:(NSDictionary *)representation
                                         ofEntity:(NSEntityDescription *)entity
                                     fromResponse:(NSHTTPURLResponse *)response{
    static NSArray *_candidateKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _candidateKeys = [[NSArray alloc] initWithObjects:@"objectId", nil];
    });
    
    NSString *key = [[representation allKeys] firstObjectCommonWithArray:_candidateKeys];
    if (key) {
        id value = [representation valueForKey:key];
        if (value) {
            return [value description];
        }
    }
    
    return nil;

}

@end
