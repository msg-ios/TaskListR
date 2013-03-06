#import "TaskListRAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kTaskListRAPIBaseURLString = @"http://arcane-refuge-8453.herokuapp.com";

@implementation TaskListRAPIClient

+ (TaskListRAPIClient *)sharedClient {
    static TaskListRAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kTaskListRAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

//Helper class method - Converts hex NSString to NSData
+ (NSData *)dataFromHexString:(NSString *)string {
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
        
    }
    
    return data;
}


#pragma mark - AFIncrementalStore

- (id)representationOrArrayOfRepresentationsFromResponseObject:(id)responseObject {
    return responseObject;
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation 
                                     ofEntity:(NSEntityDescription *)entity 
                                 fromResponse:(NSHTTPURLResponse *)response 
{
    NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
    
    // Customize the response object to fit the expected attribute keys and values  
    
    if([[mutablePropertyValues objectForKey:@"imageData"] isKindOfClass:[NSString class]])
    {
        NSMutableString *imageString = [NSMutableString stringWithString:[mutablePropertyValues objectForKey:@"imageData"]];
        
        //First and last char removal
        [imageString deleteCharactersInRange:NSMakeRange(0, 1)];
        [imageString deleteCharactersInRange:NSMakeRange([imageString length]-1, 1)];
        //Space chars removal
        [imageString stringByReplacingOccurrencesOfString:@" " withString:@""];
        //Hex string conversion
        NSData *imageData = [TaskListRAPIClient dataFromHexString:imageString];
        
        [mutablePropertyValues setObject:imageData forKey:@"imageData"];
        
    }
    
    if([[mutablePropertyValues objectForKey:@"audioData"] isKindOfClass:[NSString class]])
    {
        NSMutableString *audioString = [NSMutableString stringWithString:[mutablePropertyValues objectForKey:@"audioData"]];
        
        //First and last char removal ("<" and ">")
        [audioString deleteCharactersInRange:NSMakeRange(0, 1)];
        [audioString deleteCharactersInRange:NSMakeRange([audioString length]-1, 1)];
        //Space chars removal
        [audioString stringByReplacingOccurrencesOfString:@" " withString:@""];
        //Hex string conversion
        NSData *audioData = [TaskListRAPIClient dataFromHexString:audioString];
        
        [mutablePropertyValues setObject:audioData forKey:@"audioData"];
        
    }

    
    
    return mutablePropertyValues;
}

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
                                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
                               forObjectWithID:(NSManagedObjectID *)objectID
                        inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

@end
