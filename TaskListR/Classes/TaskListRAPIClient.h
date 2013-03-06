#import "AFIncrementalStore.h"
#import "AFRestClient.h"

@interface TaskListRAPIClient : AFRESTClient <AFIncrementalStoreHTTPClient>

+ (TaskListRAPIClient *)sharedClient;

@end
