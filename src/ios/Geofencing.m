//
//  Geofencing.m
//  GeofencingTest
//
//  Created by Daniel Mauer on 16.12.13.
//
//

#import "Geofencing.h"

#import <Cordova/CDV.h>
#import <Cordova/CDVViewController.h>
#import <CoreLocation/CoreLocation.h>



#pragma mark - Geofenfing Implementation

@implementation Geofencing

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (Geofencing*)[super initWithWebView:(UIWebView*)theWebView];
    if (self)
    {
    
    }
    return self;
}

- (BOOL) isSignificantLocationChangeMonitoringAvailable
{
    BOOL significantLocationChangeMonitoringAvailablelassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(significantLocationChangeMonitoringAvailable)];
    if (significantLocationChangeMonitoringAvailablelassPropertyAvailable)
    {
        BOOL significantLocationChangeMonitoringAvailable = [CLLocationManager significantLocationChangeMonitoringAvailable];
        return (significantLocationChangeMonitoringAvailable);
    }
    
    // by default, assume NO
    return NO;
}

- (BOOL) isRegionMonitoringAvailable
{
    BOOL regionMonitoringAvailableClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(regionMonitoringAvailable)];
    if (regionMonitoringAvailableClassPropertyAvailable)
    {
        BOOL regionMonitoringAvailable = [CLLocationManager regionMonitoringAvailable];
        return (regionMonitoringAvailable);
    }
    
    // by default, assume NO
    return NO;
}

- (BOOL) isRegionMonitoringEnabled
{
    BOOL regionMonitoringEnabledClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(regionMonitoringEnabled)];
    if (regionMonitoringEnabledClassPropertyAvailable)
    {
        BOOL regionMonitoringEnabled = [CLLocationManager regionMonitoringEnabled];
        return (regionMonitoringEnabled);
    }
    
    // by default, assume NO
    return NO;
}

- (BOOL) isAuthorized
{
    BOOL authorizationStatusClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
    if (authorizationStatusClassPropertyAvailable)
    {
        NSUInteger authStatus = [CLLocationManager authorizationStatus];
        return (authStatus == kCLAuthorizationStatusAuthorized) || (authStatus == kCLAuthorizationStatusNotDetermined);
    }
    
    // by default, assume YES (for iOS < 4.2)
    return YES;
}


- (BOOL) isLocationServicesEnabled
{
    BOOL locationServicesEnabledInstancePropertyAvailable = [[[GeofencingHelper sharedGeofencingHelper] locationManager] respondsToSelector:@selector(locationServicesEnabled)]; // iOS 3.x
    BOOL locationServicesEnabledClassPropertyAvailable = [CLLocationManager respondsToSelector:@selector(locationServicesEnabled)]; // iOS 4.x
    
    if (locationServicesEnabledClassPropertyAvailable)
    { // iOS 4.x
        return [CLLocationManager locationServicesEnabled];
    }
    else if (locationServicesEnabledInstancePropertyAvailable)
    { // iOS 2.x, iOS 3.x
        return [(id)[[GeofencingHelper sharedGeofencingHelper] locationManager] locationServicesEnabled];
    }
    else
    {
        return NO;
    }
}


#pragma mark Plugin Functions

-(void)addRegion:(CDVInvokedUrlCommand *)command
{
    NSString* callbackId = command.callbackId;
    
    [[GeofencingHelper sharedGeofencingHelper] saveGeofenceCallbackId:callbackId];
    [[GeofencingHelper sharedGeofencingHelper] setCommandDelegate:self.commandDelegate];
    
    if (self.isLocationServicesEnabled) {
        BOOL forcePrompt = NO;
        
        if (forcePrompt) {
            [[GeofencingHelper sharedGeofencingHelper] returnGeofenceError:PERMISSIONDENIED withMessage:nil];
            return;
        }
        
    }
    
    if (![self isAuthorized]) {
        NSString* message = nil;
        BOOL authStatusAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
        
        if (authStatusAvailable) {
            NSUInteger code = [CLLocationManager authorizationStatus];
            
            if (code == kCLAuthorizationStatusNotDetermined) {
                // could return POSITION_UNAVAILABLE but need to coordinate with other platforms
                message = @"User undecided on application's use of location services";
            } else if (code == kCLAuthorizationStatusRestricted) {
                message = @"application use of location services is restricted";
            }
        }
        //PERMISSIONDENIED is only PositionError that makes sense when authorization denied
        [[GeofencingHelper sharedGeofencingHelper] returnGeofenceError:PERMISSIONDENIED withMessage: message];
        
        return;
    }
    
    if (![self isRegionMonitoringAvailable])
    {
        [[GeofencingHelper sharedGeofencingHelper] returnGeofenceError:REGIONMONITORINGUNAVAILABLE withMessage: @"Region monitoring is unavailable"];
        return;
    }
    
    if (![self isRegionMonitoringEnabled])
    {
        [[GeofencingHelper sharedGeofencingHelper] returnGeofenceError:REGIONMONITORINGPERMISSIONDENIED withMessage: @"User has restricted the use of region monitoring"];
        return;
    }
    

    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    
    [self addRegionToMonitor:options];
    [[GeofencingHelper sharedGeofencingHelper] returnRegionSuccess];
    
    NSLog(@"addRegions: options: %@", options);
}


- (void) addRegionToMonitor:(NSMutableDictionary *)params {
    // Parse Incoming Params

    NSString *regionId = [[params objectForKey:KEY_REGION_ID] stringValue];
    NSString *latitude = [params objectForKey:KEY_REGION_LAT];
    NSString *longitude = [params objectForKey:KEY_REGION_LNG];
    double radius = [[params objectForKey:KEY_REGION_RADIUS] doubleValue];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coord radius:radius identifier:regionId];
    NSLog(@"Geofencing_old: Region: %@", region);
    
    [[[GeofencingHelper sharedGeofencingHelper] locationManager] startMonitoringForRegion:region desiredAccuracy:kCLLocationAccuracyBestForNavigation];
}


- (void) removeRegionToMonitor:(NSMutableDictionary *)params {
    // Parse Incoming Params
//    NSString *regionId = [params objectForKey:KEY_REGION_ID];
    NSString *regionId = [[params objectForKey:KEY_REGION_ID] stringValue];
    NSString *latitude = [params objectForKey:KEY_REGION_LAT];
    NSString *longitude = [params objectForKey:KEY_REGION_LNG];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coord radius:10.0 identifier:regionId];
    [[[GeofencingHelper sharedGeofencingHelper] locationManager] stopMonitoringForRegion:region];
}


- (void)removeRegion:(CDVInvokedUrlCommand*)command {
    
    NSString* callbackId = command.callbackId;
    NSLog(@"removeRegion.callbackId: %@", callbackId);
    NSLog(@"removeRegion.command.arguments: %@", command.arguments);
    [[GeofencingHelper sharedGeofencingHelper] saveGeofenceCallbackId:callbackId];
    [[GeofencingHelper sharedGeofencingHelper] setCommandDelegate:self.commandDelegate];
    
    
    NSLog(@"isLocationServicesEnabled: %hhd", [self isLocationServicesEnabled]);
    if (![self isLocationServicesEnabled])
    {
        BOOL forcePrompt = NO;
        NSLog(@"removeRegion.forcePromt: %hhd", forcePrompt);
        if (!forcePrompt)
        {
            NSLog(@"removeRegion.forcePromt: %hhd", forcePrompt);
            [[GeofencingHelper sharedGeofencingHelper] returnGeofenceError:PERMISSIONDENIED withMessage: nil];
            return;
        }
    }
    
    if (![self isAuthorized])
    {
        NSString* message = nil;
        BOOL authStatusAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
        if (authStatusAvailable) {
            NSUInteger code = [CLLocationManager authorizationStatus];
            if (code == kCLAuthorizationStatusNotDetermined) {
                // could return POSITION_UNAVAILABLE but need to coordinate with other platforms
                message = @"User undecided on application's use of location services";
            } else if (code == kCLAuthorizationStatusRestricted) {
                message = @"application use of location services is restricted";
            }
        }
        //PERMISSIONDENIED is only PositionError that makes sense when authorization denied
        [[GeofencingHelper sharedGeofencingHelper] returnGeofenceError:PERMISSIONDENIED withMessage: message];
        
        return;
    }
    
    if (![self isRegionMonitoringAvailable])
    {
        [[GeofencingHelper sharedGeofencingHelper] returnGeofenceError:REGIONMONITORINGUNAVAILABLE withMessage: @"Region monitoring is unavailable"];
        return;
    }
    
    if (![self isRegionMonitoringEnabled])
    {
        [[GeofencingHelper sharedGeofencingHelper] returnGeofenceError:REGIONMONITORINGPERMISSIONDENIED withMessage: @"User has restricted the use of region monitoring"];
        return;
    }

    NSMutableDictionary *options = [command.arguments objectAtIndex:0];
    [self removeRegionToMonitor:options];
    
    [[GeofencingHelper sharedGeofencingHelper] returnRegionSuccess];
}


-(void)setHost:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSString* host = [command.arguments objectAtIndex:0];
    
    // Save the host into ne nsuserdefaults
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:host forKey:@"GeofencingHost"];
    [preferences synchronize]; //at the end of storage
    
    // Load the storage data from nsuserdefaults
    //NSString *getHost = [preferences stringForKey:@"GeofencingHost"];
    //NSLog(@"nsuserdefaults Ausgabe: %@", getHost);
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@", host]];
    if (callbackId) {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
}


-(void)setToken:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSString* token = [command.arguments objectAtIndex:0];
    
    // Save the host into ne nsuserdefaults
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:token forKey:@"Usertoken"];
    [preferences synchronize]; //at the end of storage
    
    // Load the storage data from nsuserdefaults
    //NSString *getUsertoken = [preferences stringForKey:@"Usertoken"];
    //NSLog(@"nsuserdefaults Ausgabe: %@", getUsertoken);
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"%@", token]];
    if (callbackId) {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }
}



- (void)getWatchedRegionIds:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = command.callbackId;
    
    NSSet *regions = [[GeofencingHelper sharedGeofencingHelper] locationManager].monitoredRegions;
    NSLog(@"Regions 111: %@", regions);
    NSLog(@"getWatchedRegionIds.regions: %@", regions);
    NSMutableArray *watchedRegions = [NSMutableArray array];
    for (CLRegion *region in regions) {
        [watchedRegions addObject:region.identifier];
        NSLog(@"region.identifier: %@", region.identifier);
    }
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:3];
    [posError setObject: [NSNumber numberWithInt: CDVCommandStatus_OK] forKey:@"code"];
    [posError setObject: @"Region Success" forKey: @"message"];
    [posError setObject: watchedRegions forKey: @"regionids"];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:posError];
    if (callbackId) {
        //        [self writeJavascript:[result toSuccessCallbackString:callbackId]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }


    
    NSLog(@"watchedRegions: %@", watchedRegions);
}


- (void) startMonitoringSignificantLocationChanges:(CDVInvokedUrlCommand*)command {

    NSString* callbackId = command.callbackId;
    NSLog(@"MonitoringSignificationChanges: %@", command.arguments);
    
    [[GeofencingHelper sharedGeofencingHelper] saveLocationCallbackId:callbackId];
    [[GeofencingHelper sharedGeofencingHelper] setCommandDelegate:self.commandDelegate];
    
    NSLog(@"isLocationServicesEnabled %hhd", [self isLocationServicesEnabled]);
    if (![self isLocationServicesEnabled])
    {
        BOOL forcePrompt = NO;
        if (!forcePrompt)
        {
            [[GeofencingHelper sharedGeofencingHelper] returnLocationError:PERMISSIONDENIED withMessage: nil];
            return;
        }
    }

    NSLog(@"isAuthorized %hhd", [self isAuthorized]);
    if (![self isAuthorized])
    {
        NSString* message = nil;
        BOOL authStatusAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
        if (authStatusAvailable) {
            NSUInteger code = [CLLocationManager authorizationStatus];
            if (code == kCLAuthorizationStatusNotDetermined) {
                // could return POSITION_UNAVAILABLE but need to coordinate with other platforms
                message = @"User undecided on application's use of location services";
            } else if (code == kCLAuthorizationStatusRestricted) {
                message = @"application use of location services is restricted";
            }
        }
        //PERMISSIONDENIED is only PositionError that makes sense when authorization denied
        [[GeofencingHelper sharedGeofencingHelper] returnLocationError:PERMISSIONDENIED withMessage: message];
        
        return;
    }
    
    NSLog(@"isSignificantLocationChangeMonitoringAvailable: %hhd", [self isSignificantLocationChangeMonitoringAvailable]);
    if (![self isSignificantLocationChangeMonitoringAvailable])
    {
        [[GeofencingHelper sharedGeofencingHelper] returnLocationError:SIGNIFICANTLOCATIONMONITORINGUNAVAILABLE withMessage: @"Significant location monitoring is unavailable"];
        return;
    }
    
    [[[GeofencingHelper sharedGeofencingHelper] locationManager] startMonitoringSignificantLocationChanges];
    NSLog(@"------ ENDE -----");
}


- (void) stopMonitoringSignificantLocationChanges:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = command.callbackId;
    
    [[GeofencingHelper sharedGeofencingHelper] saveLocationCallbackId:callbackId];
    [[GeofencingHelper sharedGeofencingHelper] setCommandDelegate:self.commandDelegate];
    
    if (![self isLocationServicesEnabled])
    {
        BOOL forcePrompt = NO;
        if (!forcePrompt)
        {
            [[GeofencingHelper sharedGeofencingHelper] returnLocationError:PERMISSIONDENIED withMessage: nil];
            return;
        }
    }
    
    if (![self isAuthorized])
    {
        NSString* message = nil;
        BOOL authStatusAvailable = [CLLocationManager respondsToSelector:@selector(authorizationStatus)]; // iOS 4.2+
        if (authStatusAvailable) {
            NSUInteger code = [CLLocationManager authorizationStatus];
            if (code == kCLAuthorizationStatusNotDetermined) {
                // could return POSITION_UNAVAILABLE but need to coordinate with other platforms
                message = @"User undecided on application's use of location services";
            } else if (code == kCLAuthorizationStatusRestricted) {
                message = @"application use of location services is restricted";
            }
        }
        //PERMISSIONDENIED is only PositionError that makes sense when authorization denied
        [[GeofencingHelper sharedGeofencingHelper] returnLocationError:PERMISSIONDENIED withMessage: message];
        
        return;
    }
    
    if (![self isSignificantLocationChangeMonitoringAvailable])
    {
        [[GeofencingHelper sharedGeofencingHelper] returnLocationError:SIGNIFICANTLOCATIONMONITORINGUNAVAILABLE withMessage: @"Significant location monitoring is unavailable"];
        return;
    }
    
    [[[GeofencingHelper sharedGeofencingHelper] locationManager] stopMonitoringSignificantLocationChanges];
    [[GeofencingHelper sharedGeofencingHelper] returnLocationSuccess];
}

- (void) getPendingRegionUpdates:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = command.callbackId;
    
    NSString *path = [GeofencingHelper applicationDocumentsDirectory];
    NSString *finalPath = [path stringByAppendingPathComponent:@"notifications.txt"];
    NSMutableArray *updates = [NSMutableArray arrayWithContentsOfFile:finalPath];
    
    if (updates) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:finalPath error:&error];
    } else {
        updates = [NSMutableArray array];
    }
    
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:3];
    [posError setObject: [NSNumber numberWithInt: CDVCommandStatus_OK] forKey:@"code"];
    [posError setObject: @"Region Success" forKey: @"message"];
    [posError setObject: updates forKey: @"pendingupdates"];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:posError];
    if (callbackId) {
        //[self writeJavascript:[result toSuccessCallbackString:callbackId]];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
    
 
    NSLog(@"pendingupdates: %@", updates);
}

@end
