//
//  GeofencingHelper.h
//  GeofencingTest
//
//  Created by Daniel Mauer on 16.12.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Cordova/CDVJSON.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDV.h>
#import <MapKit/MapKit.h>


enum LocationStatus {
    PERMISSIONDENIED = 1,
    POSITIONUNAVAILABLE,
    TIMEOUT,
    REGIONMONITORINGPERMISSIONDENIED,
    REGIONMONITORINGUNAVAILABLE,
    SIGNIFICANTLOCATIONMONITORINGUNAVAILABLE
};
typedef NSInteger LocationStatus;

enum LocationAccuracy {
    LocationAccuracyBestForNavigation,
    LocationAccuracyBest,
    LocationAccuracyNearestTenMeters,
    LocationAccuracyHundredMeters,
    LocationAccuracyThreeKilometers
};
typedef NSInteger LocationAccuracy;

#pragma mark - LocationData Interface

@interface LocationData : NSObject

@property (nonatomic, assign) LocationStatus locationStatus;
@property (nonatomic, retain) CLLocation* locationInfo;
@property (nonatomic, retain) NSMutableArray* locationCallbacks;
@property (nonatomic, retain) NSMutableArray* geofenceCallbacks;

@end


#pragma mark - Geofencing Helper Interface
@class CDVWebViewDelegate;
@class CDVViewController;
@class CDVPlugin;
@class UIWebView;
@interface GeofencingHelper : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager* locationManager;
@property (nonatomic, assign) UIWebView* webView;
@property (nonatomic, assign) BOOL didLaunchForRegionUpdate;
@property (nonatomic, retain) LocationData* locationData;
@property (nonatomic, assign) id <CDVCommandDelegate> commandDelegate;

+(GeofencingHelper*)sharedGeofencingHelper;

+ (NSString*) applicationDocumentsDirectory;

- (void) returnLocationError: (NSUInteger) errorCode withMessage: (NSString*) message;
- (void) returnGeofenceError: (NSUInteger) errorCode withMessage: (NSString*) message;

- (void) returnRegionSuccess;
- (void) returnLocationSuccess;

- (void) saveGeofenceCallbackId:(NSString *) callbackId;
- (void) saveLocationCallbackId:(NSString *) callbackId;

@end
