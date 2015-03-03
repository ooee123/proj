//
//  GradebookURLLoader.h
//  AuthTest
//
//  Created by John Bellardo on 2/6/12.
//  Copyright (c) 2012 California State Polytechnic University, San Luis Obispo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GradebookReqMethod @"method"
#define GradebookReqContentType @"content type"
#define GradebookReqBody @"body"

@interface GradebookURLLoader : NSObject<NSURLConnectionDelegate>

/* Stores the base URL for the gradebook server.  See the assignment specs for
 * the actual URL to use.
 */
@property (nonatomic, copy) NSString *baseURL;

/* Logs in to the gradebook JSON server.  Must set the baseURL property before calling this method.
 *
 * Returns YES if login was successful, NO otherwiese.
 */
- (BOOL) loginWithUsername: (NSString*) username andPassword: (NSString*) password;

/* Performs a simple HTTP "GET" operaton to load JSON data.  The urlSuffix is
 * effectively appended to the baseURL to for the actual URL that is loaded.
 * err is an out parameter, set when a loading error has occurred.  Pass
 * nil into err if you aren't interested in receiving this NSError object.
 *
 * Returns an NSData object containing the loaded page data, or nil
 * if an error occurred during the load operation.
 */
- (NSData*) loadDataFromPath: (NSString*) urlSuffix error: (NSError**) err;

/*
 * A more fully-featured version of loadDataFromPath:error:.  The urlSuffix parameter,
 *  err parameter, and return value work exactly the same as loadDataFromPath:error:.
 *  The status out parameter contains the HTTP status code.  Set status to nil if you
 *  aren't interested in this piece of information.  The reqDict provides a generic
 *  mechanism for modifying the HTTP request.  All values in the dictionary must be strings. 
 *  All keys are optional.  The supported keys are macros defined in this header file:
 *
 *     GradebookReqMethod -- Controls the HTTP method.  The default is "GET".
 *                           "PUT" and "POST" are also support methods.
 *
 *     GradebookReqContentType -- Used verbatim as the HTTP Content-Type request header.
 *                                Default is to not include a Content-Type header.
 *     GradebookReqBody -- The data uploaded with the HTTP request.  The default is
 *                         to upload no additional data.
 */
- (NSData*) loadDataFromPath: (NSString*) urlSuffix
             withRequestDict:(NSDictionary*) reqDict
             returningStatus: (NSInteger*) status
                       error: (NSError**) err;

/*
 * Returns the URLRequest that will be loaded for a given path and request dictionary.
 *  This includes all applicable authentication headers, suitable for use in a UIWebView.
 */
- (NSMutableURLRequest*) requestForPath: (NSString*)urlSuffix
                        withRequestDict: (NSDictionary*) reqDict;

@end
