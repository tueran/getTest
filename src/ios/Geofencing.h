//
//  Geofencing.h
//  GeofencingTest
//
//  Created by Daniel Mauer on 16.12.13.
//
//

//#import <Cordova/Cordova.h>

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDV.h>
#import <CoreLocation/CoreLocation.h>
#import "GeofencingHelper.h"
#import <MapKit/MapKit.h>

#define KEY_REGION_ID @"fid"
#define KEY_REGION_LAT @"latitude"
#define KEY_REGION_LNG @"longitude"
#define KEY_REGION_RADIUS @"radius"
#define KEY_REGION_ACCURACY @"accuracy"

@interface Geofencing : CDVPlugin <CLLocationManagerDelegate>

- (BOOL) isLocationServicesEnabled;
- (BOOL) isAuthorized;
- (BOOL) isRegionMonitoringAvailable;
- (BOOL) isRegionMonitoringEnabled;
- (BOOL) isSignificantLocationChangeMonitoringAvailable;
- (void) addRegionToMonitor:(NSMutableDictionary *)params;
- (void) removeRegionToMonitor:(NSMutableDictionary *)params;


#pragma mark Plugin Functions
- (void) addRegion:(CDVInvokedUrlCommand*)command;
- (void) setHost:(CDVInvokedUrlCommand*)command;
- (void) setToken:(CDVInvokedUrlCommand*)command;
- (void) removeRegion:(CDVInvokedUrlCommand*)command;
- (void) getWatchedRegionIds:(CDVInvokedUrlCommand*)command;
- (void) getPendingRegionUpdates:(CDVInvokedUrlCommand*)command;
- (void) startMonitoringSignificantLocationChanges:(CDVInvokedUrlCommand*)command;
- (void) stopMonitoringSignificantLocationChanges:(CDVInvokedUrlCommand*)command;

@end
