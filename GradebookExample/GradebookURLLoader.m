//
//  GradebookURLLoader.m
//  AuthTest
//
//  Created by John Bellardo on 2/6/12.
//  Copyright (c) 2012 California State Polytechnic University, San Luis Obispo. All rights reserved.
//

#import "GradebookURLLoader.h"
#import "NSString+Base64Encoding.h"

#define AuthTypeNone 0
#define AuthTypeBasic 1
#define AuthTypeCAS 2
#define AuthTypeTempDisable 3

#define CredsRedirect 2
#define CredsValid 1
#define CredsInvalid 0

#define NO_OPERATION 1
#define OPERATION_INPROGRESS 2
#define OPERATION_DONE 3

@interface GradebookURLLoader ()
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic) int authType;
@property (nonatomic, strong) NSConditionLock *lock;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSError *connErr;
@property (nonatomic, strong) NSURLResponse *connResp;
@property (nonatomic, strong) NSThread *loaderThread;
@property (nonatomic, strong) NSRunLoop *loaderRunLoop;
@property (nonatomic, strong) NSURLRequest *lastURLRequest;

- (int) validateCredentials;
- (NSArray*) parseCASFormInputs: (NSString*) casForm;
- (NSDictionary*) parseInputLine: (NSString*)form withRange: (NSRange) lineRange;
- (NSData*) extractCASForm: (NSData*)orgPage;
- (NSData*) attemptCASLogin: (NSData*) casForm returningStatus: (NSInteger*) status baseURL: (NSURL*) url;
- (NSString*) getAttributeNamed: (NSString*)attrName fromString:(NSString*) str inRange: (NSRange) searchRange;
- (void) loopThread: (id) obj;

@end

@implementation GradebookURLLoader
@synthesize baseURL = _baseURL;
@synthesize username = _username;
@synthesize password = _password;
@synthesize authType = _authType;
@synthesize lock = _lock;
@synthesize receivedData = _receivedData;
@synthesize connErr = _connErr;
@synthesize connResp = _connResp;
@synthesize loaderThread = _loaderThread;
@synthesize loaderRunLoop = _loaderRunLoop;
@synthesize lastURLRequest = _lastURLRequest;

- (void) doFireTimer:(id)foo
{
}

- (void) loopThread: (NSThread*) myThread
{
    self.loaderRunLoop = [NSRunLoop currentRunLoop];
    
    NSTimer *keepalive = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:30]
                             interval:30
                               target:self
                             selector:@selector(doFireTimer:)
                             userInfo:nil
                              repeats:YES];
    [self.loaderRunLoop addTimer:keepalive
                         forMode:NSDefaultRunLoopMode];
    
    while (![self.loaderThread isCancelled] &&
           [self.loaderRunLoop runMode:NSDefaultRunLoopMode
                            beforeDate:[NSDate distantFuture]])
        ;
}

- (id) init
{
    self = [super init];
    self.lock = [[NSConditionLock alloc] initWithCondition:NO_OPERATION];
    self.loaderThread = [[NSThread alloc] initWithTarget:self
                                                selector:@selector(loopThread:)
                                                  object:nil];
    [self.loaderThread start];
    
    return self;
}

- (NSData*) loadDataFromPath: (NSString*) urlSuffix error: (NSError**) err
{
    return [self loadDataFromPath:urlSuffix withRequestDict: nil returningStatus:nil error:err];
}

- (NSMutableURLRequest*) requestForPath: (NSString*)urlSuffix
             withRequestDict: (NSDictionary*) reqDict
{
    NSURL *url = [NSURL URLWithString:urlSuffix
                        relativeToURL: [NSURL URLWithString: self.baseURL]];
    
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:60];

    if (self.authType == AuthTypeBasic && [url.scheme isEqualToString:@"https"]) {
        NSString *loginString = [NSString stringWithFormat:@"%@:%@", self.username, self.password];         
        [req addValue:[NSString stringWithFormat:@"Basic %@", [loginString base64Encode]]
                forHTTPHeaderField:@"Authorization"];
    }
    
    if (reqDict) {
        if ([reqDict valueForKey:GradebookReqMethod])
            [req setHTTPMethod:[reqDict valueForKey:GradebookReqMethod]];
        
        if ([reqDict valueForKey:GradebookReqContentType])
            [req setValue:[reqDict valueForKey:GradebookReqContentType]
       forHTTPHeaderField:@"Content-Type"];
        
        if ([reqDict valueForKey:GradebookReqBody])
            [req setHTTPBody:[reqDict valueForKey:GradebookReqBody]];
    }
    
    return req;
}

- (NSData*) loadDataFromPath: (NSString*)urlSuffix
             withRequestDict: (NSDictionary*) reqDict
             returningStatus: (NSInteger*) status
                       error:(NSError**) errRet
{
	NSMutableURLRequest *req = [self requestForPath:urlSuffix
                                    withRequestDict:reqDict];
    
    if (status)
        *status = 0;

    [self.lock lockWhenCondition:NO_OPERATION];
    
    self.lastURLRequest = req;
	self.receivedData = [[NSMutableData alloc] init];
    self.connErr = nil;
    self.connResp = nil;
    
    [self.lock unlockWithCondition:OPERATION_INPROGRESS];

    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:self
                             startImmediately:NO];

    [conn scheduleInRunLoop:self.loaderRunLoop
                    forMode:NSDefaultRunLoopMode];
    [conn start];
    
    [self.lock lockWhenCondition:OPERATION_DONE];
    
    // Grab a private copy of important connection data
    // before unlocking the lock     
    NSData *data = self.receivedData;
    self.receivedData = nil;
    NSError *err = self.connErr;
    self.connErr = nil;
	NSURLResponse *resp = self.connResp;
    self.connResp = nil;
    
    [self.lock unlockWithCondition:NO_OPERATION];

    if ([resp isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*)resp;
        if (status)
            *status = [httpResp statusCode];
    }
    
    if (err) {
        // 401 (authentication needed) errors don't come back with a response
        // Fake the 401 status code given the correct combination of
        // values in the error object
        if ([err.domain isEqualToString:NSURLErrorDomain] &&
            err.code == -1012 && status) 
            *status = 401;
        
        if (!status || !*status)
            data = nil;
        if (errRet)
            *errRet = err;
    }
    
    if (self.authType == AuthTypeCAS) {
        NSData *casData = [self extractCASForm: data];
        if (!casData)
            return data;
        
        return [self attemptCASLogin:casData
                     returningStatus:status 
                             baseURL: [self.lastURLRequest URL]];
    }

    return data;
}

- (NSData*) extractCASForm: (NSData*)orgPage
{
    NSRange beginCASRange, endCASRange, searchRange;
    
    if (!orgPage)
        return nil;
    
    // Find the begin CAS comment
    searchRange.location = 0;
    searchRange.length = orgPage.length;
    NSData *beginCASData = [@"<!-- BEGIN CAS -->" dataUsingEncoding:NSStringEncodingConversionAllowLossy];
    
    beginCASRange = [orgPage rangeOfData:beginCASData
                                 options:0
                                   range:searchRange];
    if (beginCASRange.location == NSNotFound)
        return nil;
    
    // Find the End CAS comment
    NSData *endCASData = [@"<!-- END CAS -->" dataUsingEncoding:NSStringEncodingConversionAllowLossy];
    
    endCASRange = [orgPage rangeOfData:endCASData
                                 options:0
                                   range:searchRange];
    if (endCASRange.location == NSNotFound)
        return nil;

    NSRange casFormRange;
    casFormRange.location = beginCASRange.location + beginCASRange.length;
    casFormRange.length = endCASRange.location - casFormRange.location;
    return [orgPage subdataWithRange:casFormRange];
}

- (NSString*) getAttributeNamed: (NSString*)attrName fromString:(NSString*) str inRange: (NSRange) searchRange
{
    NSError *error = NULL;
    NSString *regexPattern = [NSString stringWithFormat:@"%@=\"[^\"]*\"", attrName];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:&error];
    if (!regex)
        return nil;
    
    NSRange range = [regex rangeOfFirstMatchInString:str
                                             options:0
                                               range:searchRange];
    
    if (range.location == NSNotFound)
        return nil;
    
    // Trim off the key and quotes
    range.location += attrName.length + 2;
    range.length -= attrName.length + 3;
    
    return [str substringWithRange:range];
}

- (NSDictionary*) parseInputLine: (NSString*)form withRange: (NSRange) lineRange
{
    NSDictionary *res = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in [NSArray arrayWithObjects:@"name", @"type", @"value", nil]) {
        NSString *value = [self getAttributeNamed:key
                                       fromString:form
                                       inRange:lineRange];
        if (value)
            [res setValue:value forKey:key];
    }
    
    
    return res;
}

- (NSArray*) parseCASFormInputs: (NSString*) casForm
{
    NSMutableArray *res = [[NSMutableArray alloc] init];
    
    NSError *error = NULL;
    
    // Begin by extracting the <from...> tag
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<input[\t \r\n][^>]*>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (!regex)
        return nil;
    
    [regex enumerateMatchesInString:casForm
                            options:0
                              range:NSMakeRange(0, [casForm length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
                           {
                               NSDictionary *inpDict = [self parseInputLine:casForm withRange:[match range]];
                               if (inpDict)
                                   [res addObject:inpDict];
                         }];
    
    return res;
}

- (NSDictionary*) parseCASForm: (NSString*) casForm
{
    NSMutableDictionary *res = [[NSMutableDictionary alloc] init];
    NSError *error = NULL;
    
    // Begin by extracting the <from...> tag
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<form[\t \r\n][^>]*>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (!regex)
        return nil;
    NSRange formRange = [regex rangeOfFirstMatchInString:casForm
                                                 options:0
                                                   range:NSMakeRange(0, [casForm length])];
    if (formRange.location == NSNotFound)
        return nil;
    
    // Extract the two elements we care about (action and method)
    NSString *actionStr = [self getAttributeNamed:@"action"
                                       fromString:casForm
                                          inRange: formRange];
    if (actionStr)
        [res setValue:actionStr forKey:@"action"];

    NSString *methodStr = [self getAttributeNamed:@"method"
                                       fromString:casForm
                                          inRange: formRange];
    if (methodStr)
        [res setValue:methodStr forKey:@"method"];
    
    // Parse out all the input elements
    NSArray *inputs = [self parseCASFormInputs:casForm];
    if (inputs)
        [res setValue:inputs forKey:@"inputs"];
    
    return res;
}

- (NSData*) attemptCASLogin: (NSData*) casForm returningStatus: (NSInteger*) status baseURL: (NSURL*) url;

{
    if (!casForm)
        return nil;
    
    NSString *formString = [[NSString alloc] initWithData:casForm
                                              encoding:NSStringEncodingConversionAllowLossy];
    
    NSDictionary *casFormDict = [self parseCASForm: formString];
    if (!casFormDict)
        return nil;

    // We can only handle post requests
    if (![casFormDict valueForKey:@"method"] || 
        ![@"post" isEqualToString:[casFormDict valueForKey:@"method"]])
        return nil;

    if (![casFormDict valueForKey:@"inputs"])
        return nil;
    
    // Create the form post string
    NSMutableString *postStr = [[NSMutableString alloc] init];
    
    for (NSDictionary *input in [casFormDict valueForKey:@"inputs"]) {
        NSString *type = [input valueForKey:@"type"];
        if (!type || !([type isEqualToString:@"text"] || [type isEqualToString:@"hidden"] ||
                       [type isEqualToString:@"password"] || [type isEqualToString:@"submit"]) )
            continue;
        NSString *name = [input valueForKey:@"name"];
        if (!name)
            continue;
        NSString *value = [input valueForKey:@"value"];
        if ([name isEqualToString:@"username"])
            value = self.username;
        else if ([type isEqualToString:@"password"])
            value = self.password;
        if (!value)
            continue;
        
        if (postStr.length > 0)
            [postStr appendString:@"&"];
        [postStr appendFormat:@"%@=%@", name, value];
    }
    
    NSString *action = [casFormDict valueForKey:@"action"];
    if (!action)
        return nil;
    
    // Create the post URL
    NSURL *postUrl = [[NSURL alloc] initWithScheme:self.lastURLRequest.URL.scheme
                                              host:self.lastURLRequest.URL.host
                                              path:action];
    
    // Perform the actual post.  Assuming all went well, we expect
    // a redirect (and load) of the original content, so just return
    // this new data
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:postUrl];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:[postStr dataUsingEncoding:NSASCIIStringEncoding]];
        
    NSURLResponse *resp;
    NSError *err;
        
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                             returningResponse:&resp
                                                         error:&err];
        
    if ([resp isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*)resp;
        if (status)
            *status = [httpResp statusCode];
    }
    
    if (err) {
        // 401 (authentication needed) errors don't come back with a response
        // Fake the 401 status code given the correct combination of
        // values in the error object
        if ([err.domain isEqualToString:NSURLErrorDomain] &&
            err.code == -1012 && status) 
            *status = 401;
        
        if (!status || !*status)
            data = nil;
    }
    
    return data;
}

- (int) validateCredentials
{
    NSInteger status = 0;
    NSData *pageData;

    pageData = [self loadDataFromPath:@"auth.txt"
                      withRequestDict:nil
                      returningStatus:&status
                                error:nil];
    
    NSString *pageStr = [[NSString alloc] initWithData:pageData
                                              encoding:NSStringEncodingConversionAllowLossy];

    if (status == 200 && [pageStr isEqualToString:@"access\n"])
        return CredsValid;
    
    if (status == 200) {
        return CredsRedirect;
    }
    
    return CredsInvalid;
}

- (BOOL) loginWithUsername: (NSString*) username andPassword: (NSString*) password
{
    self.username = username;
    self.password = password;
    
    self.authType = AuthTypeNone;
    if (CredsValid == [self validateCredentials])
        return YES;
    
    self.authType = AuthTypeBasic;
    if (CredsValid == [self validateCredentials])
        return YES;
    
    self.authType = AuthTypeCAS;
    if (CredsValid == [self validateCredentials])
        return YES;
    
    self.authType = AuthTypeNone;
    return NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.lock tryLockWhenCondition:OPERATION_INPROGRESS];
    // release the connection, and the data object
    [self.lock unlockWithCondition:OPERATION_DONE];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // inform the user
    self.receivedData = nil;
    self.connErr = error;
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);

    [self.lock unlockWithCondition:OPERATION_DONE];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.lock tryLockWhenCondition:OPERATION_INPROGRESS];
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    self.connResp = response;
    [self.receivedData setLength:0];
}

- (NSURLRequest *)connection: (NSURLConnection *)inConnection
             willSendRequest: (NSURLRequest *)inRequest
            redirectResponse: (NSURLResponse *)inRedirectResponse
{
    self.lastURLRequest = inRequest;
    return inRequest;
}

@end
