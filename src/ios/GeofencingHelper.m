//
//  GeofencingHelper.m
//  GeofencingTest
//
//  Created by Daniel Mauer on 16.12.13.
//
//

#import "GeofencingHelper.h"


static GeofencingHelper *sharedGeofencingHelper = nil;

#pragma mark - LocationData Implementation

@implementation LocationData

@synthesize locationStatus, locationInfo;
@synthesize locationCallbacks;
@synthesize geofenceCallbacks;

-(LocationData*) init
{
    self = (LocationData*)[super init];
    if (self) {
        self.locationInfo = nil;
    }
    return self;
}

@end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#pragma mark - GeofencingHelper Implementation
@implementation GeofencingHelper

@synthesize webView;
@synthesize locationManager;
@synthesize locationData;
@synthesize didLaunchForRegionUpdate;
@synthesize commandDelegate;



-(void)saveGeofenceCallbackId:(NSString *)callbackId
{
    if (!self.locationData) {
        self.locationData = [[LocationData alloc] init];
    }
    
    LocationData* lData = self.locationData;
    if (!lData.geofenceCallbacks) {
        lData.geofenceCallbacks = [NSMutableArray array];
    }
    
    // add the callbackId into the array so we can call back when get data
    [lData.geofenceCallbacks enqueue:callbackId];
}

-(void)saveLocationCallbackId:(NSString *)callbackId
{
    if (!self.locationData) {
        self.locationData = [[LocationData alloc] init];
    }
    
    LocationData* lData = self.locationData;
    if (!lData.locationCallbacks) {
        lData.locationCallbacks = [NSMutableArray array];
    }
    
    // add the callbackId into the array so we cann call back when get data
    [lData.locationCallbacks enqueue:callbackId];
}


#pragma mark - location Manager

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if (self.didLaunchForRegionUpdate) {
        NSString *path = [GeofencingHelper applicationDocumentsDirectory];
        NSString *finalPath = [path stringByAppendingPathComponent:@"notifications.txt"];
        
        NSMutableArray *updates = [NSMutableArray arrayWithContentsOfFile:finalPath];
        
        if (!updates) {
            updates = [NSMutableArray array];
        }
        
        NSMutableDictionary *update = [NSMutableDictionary dictionary];
        
        [update setObject:region.identifier forKey:@"fid"];
        [update setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
        [update setObject:@"enter" forKey:@"status"];
        
        [updates addObject:update];
        
        [updates writeToFile:finalPath atomically:YES];
        
        // SITEFORUM Stuff
        
        
        
        NSLog(@"-------------------------------------");
        NSLog(@"-----> E N T E R   R E G I O N <-----");
        NSLog(@"-------------------------------------");
        
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"enter" forKey:@"status"];
        [dict setObject:region.identifier forKey:@"fid"];
        NSString *jsStatement = [NSString stringWithFormat:@"Geofencing.regionMonitorUpdate(%@);", [dict JSONString]];
        [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
        
        // Remove for GoLive and change it
        NSString *path = [GeofencingHelper applicationDocumentsDirectory];
        NSString *finalPath2 = [path stringByAppendingPathComponent:@"siteforum_geofencing.txt"];
        
        NSMutableArray *dicts = [NSMutableArray arrayWithContentsOfFile:finalPath2];
        
        if (!dicts) {
            dicts = [NSMutableArray array];
        }
        
        [dicts addObject:dict];
        [dicts writeToFile:finalPath2 atomically:YES];
        
    }
    
    
    // Load the storage data from nsuserdefaults
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *getHost = [preferences stringForKey:@"GeofencingHost"];
    NSString *getUsertoken = [preferences stringForKey:@"Usertoken"];
    NSLog(@"nsuserdefaults Ausgabe: %@", getHost);
    
    // NSURL Request
    NSString* geofencingUrl = [NSString stringWithFormat:@"https://%@/sf/regions/%@/enter?s=&token=%@", getHost, region.identifier, getUsertoken];
    //NSString* geofencingUrl = [NSString stringWithFormat:@"https://%@/sf/daniel/%@/enter?s=&token=%@", getHost, region.identifier, getUsertoken];
    NSURL* sfUrl = [NSURL URLWithString:geofencingUrl];
    NSLog(@"URL: %@", sfUrl);
    // set the request
    NSURLRequest* sfRequest = [NSURLRequest requestWithURL:sfUrl];
    NSOperationQueue* sfQueue = [[NSOperationQueue alloc] init];
    __block NSUInteger tries = 0;
    
    typedef void (^CompletionBlock)(NSURLResponse *, NSData *, NSError *);
    __block CompletionBlock completionHandler = nil;
    
    // Block to start the request
    dispatch_block_t enqueueBlock = ^{
        [NSURLConnection sendAsynchronousRequest:sfRequest queue:sfQueue completionHandler:completionHandler];
    };
    
    completionHandler = ^(NSURLResponse *sfResponse, NSData *sfData, NSError *sfError) {
        tries++;
        if (sfError) {
            if (tries < 3) {
                enqueueBlock();
                NSLog(@"Error: %@", sfError);
            } else {
                NSLog(@"Abbruch nach 3 Versuchen.");
            }
        } else {
            NSString* myResponse;
            myResponse = [[NSString alloc] initWithData:sfData encoding:NSUTF8StringEncoding];
            NSLog(@"Response: %@", myResponse);
            
            NSLog(@"----------------------------------------------------------");
            NSLog(@"-----> E N T E R   R E G I O N   C O N D I T I O N  <-----");
            NSLog(@"----------------------------------------------------------");
        }
    };
    
    enqueueBlock();
    
    
    
    
}


- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if (self.didLaunchForRegionUpdate) {
        NSString *path = [GeofencingHelper applicationDocumentsDirectory];
        NSString *finalPath = [path stringByAppendingPathComponent:@"notifications.txt"];
        NSMutableArray *updates = [NSMutableArray arrayWithContentsOfFile:finalPath];
        
        if (!updates) {
            updates = [NSMutableArray array];
        }
        
        NSMutableDictionary *update = [NSMutableDictionary dictionary];
        
        [update setObject:region.identifier forKey:@"fid"];
        [update setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
        [update setObject:@"left" forKey:@"status"];
        
        [updates addObject:update];
        
        [updates writeToFile:finalPath atomically:YES];
        
        
        
        
        
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"left" forKey:@"status"];
        [dict setObject:region.identifier forKey:@"fid"];
        NSString *jsStatement = [NSString stringWithFormat:@"Geofencing.regionMonitorUpdate(%@);", [dict JSONString]];
        [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
        
        
        // Remove for GoLive and change it
        
        NSString *path = [GeofencingHelper applicationDocumentsDirectory];
        NSString *finalPath2 = [path stringByAppendingPathComponent:@"siteforum_geofencing.txt"];
        
        NSMutableArray *dicts = [NSMutableArray arrayWithContentsOfFile:finalPath2];
        
        if (!dicts) {
            dicts = [NSMutableArray array];
        }
        
        [dicts addObject:dict];
        [dicts writeToFile:finalPath2 atomically:YES];

    }
    
    
    
    // Load the storage data from nsuserdefaults
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *getHost = [preferences stringForKey:@"GeofencingHost"];
    NSString *getUsertoken = [preferences stringForKey:@"Usertoken"];
    NSLog(@"nsuserdefaults Ausgabe: %@", getHost);
    
    // NSURL Request
    NSString* geofencingUrl = [NSString stringWithFormat:@"https://%@/sf/regions/%@/exit?s=&token=%@", getHost, region.identifier, getUsertoken];
    //NSString* geofencingUrl = [NSString stringWithFormat:@"https://%@/sf/daniel/%@/exit?s=&token=%@", getHost, region.identifier, getUsertoken];
    NSURL* sfUrl = [NSURL URLWithString:geofencingUrl];
    NSLog(@"URL: %@", sfUrl);

    // set the request
    NSURLRequest* sfRequest = [NSURLRequest requestWithURL:sfUrl];
    NSOperationQueue* sfQueue = [[NSOperationQueue alloc] init];
    __block NSUInteger tries = 0;
    
    typedef void (^CompletionBlock)(NSURLResponse *, NSData *, NSError *);
    __block CompletionBlock completionHandler = nil;
    
    // Block to start the request
    dispatch_block_t enqueueBlock = ^{
        [NSURLConnection sendAsynchronousRequest:sfRequest queue:sfQueue completionHandler:completionHandler];
    };
    
    completionHandler = ^(NSURLResponse *sfResponse, NSData *sfData, NSError *sfError) {
        tries++;
        if (sfError) {
            if (tries < 3) {
                enqueueBlock();
                NSLog(@"Error: %@", sfError);
            } else {
                NSLog(@"Abbruch nach 3 Versuchen.");
            }
        } else {
            NSString* myResponse;
            myResponse = [[NSString alloc] initWithData:sfData encoding:NSUTF8StringEncoding];
            NSLog(@"Response: %@", myResponse);
            
            NSLog(@"----------------------------------------------------------");
            NSLog(@"----->  E X I T   R E G I O N   C O N D I T I O N   <-----");
            NSLog(@"----------------------------------------------------------");
        }
    };
    
    enqueueBlock();
    
    
    
    
    
}


-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithDouble:[newLocation.timestamp timeIntervalSince1970]] forKey:@"new_timestamp"];
    [dict setObject:[NSNumber numberWithDouble:newLocation.speed] forKey:@"new_speed"];
    [dict setObject:[NSNumber numberWithDouble:newLocation.course] forKey:@"new_course"];
    [dict setObject:[NSNumber numberWithDouble:newLocation.verticalAccuracy] forKey:@"new_verticalAccuracy"];
    [dict setObject:[NSNumber numberWithDouble:newLocation.horizontalAccuracy] forKey:@"new_horizontalAccuracy"];
    [dict setObject:[NSNumber numberWithDouble:newLocation.altitude] forKey:@"new_altitude"];
    [dict setObject:[NSNumber numberWithDouble:newLocation.coordinate.latitude] forKey:@"new_latitude"];
    [dict setObject:[NSNumber numberWithDouble:newLocation.coordinate.longitude] forKey:@"new_longitude"];
    
    [dict setObject:[NSNumber numberWithDouble:[oldLocation.timestamp timeIntervalSince1970]] forKey:@"old_timestamp"];
    [dict setObject:[NSNumber numberWithDouble:oldLocation.speed] forKey:@"old_speed"];
    [dict setObject:[NSNumber numberWithDouble:oldLocation.course] forKey:@"oldcourse"];
    [dict setObject:[NSNumber numberWithDouble:oldLocation.verticalAccuracy] forKey:@"old_verticalAccuracy"];
    [dict setObject:[NSNumber numberWithDouble:oldLocation.horizontalAccuracy] forKey:@"old_horizontalAccuracy"];
    [dict setObject:[NSNumber numberWithDouble:oldLocation.altitude] forKey:@"old_altitude"];
    [dict setObject:[NSNumber numberWithDouble:oldLocation.coordinate.latitude] forKey:@"old_latitude"];
    [dict setObject:[NSNumber numberWithDouble:oldLocation.coordinate.longitude] forKey:@"old_longitude"];
    
    NSString *jsStatement = [NSString stringWithFormat:@"Geofencing.locationMonitorUpdate(%@);", [dict JSONString]];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStatement];
    
    // Remove for GoLive and change it
    
    NSString *path = [GeofencingHelper applicationDocumentsDirectory];
    NSString *finalPath2 = [path stringByAppendingPathComponent:@"siteforum_geofencing_didUpdateToLocation_fromLocation.txt"];
    
    NSMutableArray *dicts = [NSMutableArray arrayWithContentsOfFile:finalPath2];
    
    if (!dicts) {
        dicts = [NSMutableArray array];
    }
    
    [dicts addObject:dict];
    [dicts writeToFile:finalPath2 atomically:YES];

    
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [posError setObject: [NSNumber numberWithInt: error.code] forKey:@"code"];
    [posError setObject: region.identifier forKey: @"regionid"];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
    for (NSString *callbackId in self.locationData.geofenceCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }
    

    
    self.locationData.geofenceCallbacks = [NSMutableArray array];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    [posError setObject: [NSNumber numberWithInt: error.code] forKey:@"code"];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
    for (NSString *callbackId in self.locationData.locationCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }
    

    
    self.locationData.locationCallbacks = [NSMutableArray array];
}








- (void) returnRegionSuccess; {
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    [posError setObject: [NSNumber numberWithInt: CDVCommandStatus_OK] forKey:@"code"];
    [posError setObject: @"Region Success" forKey: @"message"];
    
  
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:posError];
    for (NSString *callbackId in self.locationData.geofenceCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }
    self.locationData.geofenceCallbacks = [NSMutableArray array];
}


- (void) returnLocationSuccess; {
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    [posError setObject: [NSNumber numberWithInt: CDVCommandStatus_OK] forKey:@"code"];
    [posError setObject: @"Region Success" forKey: @"message"];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:posError];
    for (NSString* callbackId in self.locationData.locationCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }
    

    self.locationData.locationCallbacks = [NSMutableArray array];
}


- (void) returnLocationError: (NSUInteger) errorCode withMessage: (NSString*) message
{
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    [posError setObject: [NSNumber numberWithInt: errorCode] forKey:@"code"];
    [posError setObject: message ? message : @"" forKey: @"message"];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:posError];
    for (NSString *callbackId in self.locationData.locationCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }
    
    self.locationData.locationCallbacks = [NSMutableArray array];
}

- (void) returnGeofenceError: (NSUInteger) errorCode withMessage: (NSString*) message
{
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    [posError setObject: [NSNumber numberWithInt: errorCode] forKey:@"code"];
    [posError setObject: message ? message : @"" forKey: @"message"];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
    for (NSString *callbackId in self.locationData.geofenceCallbacks) {
        if (callbackId) {
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }
    

    
    self.locationData.geofenceCallbacks = [NSMutableArray array];
}

- (id) init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // Tells the location manager to send updates to this object
        self.locationData = nil;

    }
    return self;
}

+(GeofencingHelper *)sharedGeofencingHelper
{
    //objects using shard instance are responsible for retain/release count
    //retain count must remain 1 to stay in mem
    
    if (!sharedGeofencingHelper)
    {
        sharedGeofencingHelper = [[GeofencingHelper alloc] init];
    }
    
    return sharedGeofencingHelper;
}


+ (NSString*) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
 
