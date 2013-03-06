#import "AFIncrementalStore.h"
#import "AFRestClient.h"

@interface TaskListRAPIClient : AFRESTClient <AFIncrementalStoreHTTPClient>

+ (TaskListRAPIClient *)sharedClient;

+ (NSData *)dataFromHexString:(NSString *)string;

@end
