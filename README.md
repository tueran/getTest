# Example of Geofencing.


## Installation

- Make sure that you have [Node](http://nodejs.org/) and [PhoneGap CLI](https://github.com/mwbrooks/phonegap-cli) installed on your machine.
- Create your PhoneGap example app

```bash
phonegap create com.siteforum.TestApp && cd $_
```

- Add the plugin to it

```bash
phonegap local plugin add https://github.com/tueran/Geofencing.git
```

## INCLUDED FUNTIONS

Geofencing.js contains the following functions:

    initCallbackForRegionMonitoring - Initializes the PhoneGap Plugin callback.
    startMonitoringRegion - Starts monitoring a region.
    stopMonitoringRegion - Clears an existing region from being monitored.
    getWatchedRegionIds - Returns a list of currently monitored region identifiers.
    startMonitoringSignificantLocationChanges - Starts monitoring significant location changes.
    stopMonitoringSignificantLocationChanges - Stops monitoring significant location changes.


## PLUGIN CODE EXAMPLE

To add a new region to be monitored use the Geofencing startMonitoringRegion function. The parameters are:

    fid - String - This is a unique identifier.
    latitude - String - latitude of the region.
    longitude - String - latitude of the region.
    radius - Integer - Specifies the radius in meters of the region.
    accuracy - Integer - Specifies the accuracy in meters.

Example:
```bash
var params = [location.id, location.location.lat, location.location.lng, "10", "3"];
Geofencing.startMonitoringRegion(params, function(result) {}, function(error) {
    alert("failed to add region");
});
```

To remove an existing region use the Geofencing removeRegion function. The parameters are: 1. fid - String - This is a unique identifier. 2. latitude - String - latitude of the region. 3. longitude - String - latitude of the region.

Example:
```bash
var params = [item.fid, item.latitude, item.longitude];
Geofencing.stopMonitoringRegion(params, 
function(result) {

    // not used.

}, function(error) {
    // not used
});
```


To retrieve the list of identifiers of currently monitored regions use the Geofencing getWatchedRegionIds function. No parameters.
The result object contains an array of strings in regionids

Example:

```bash
Geofencing.getWatchedRegionIds(
    function(result) { 
        alert("success: " + result.regionids);                 
    },
    function(error) {  
        alert("error");   
    }
);
```

To start monitoring signifaction location changes use the Geofencing startMonitoringSignificantLocationChanges function. No parameters.

Example:
```bash
Geofencing.startMonitoringSignificantLocationChanges(
    function(result) { 
        console.log("Location Monitor Success: " + result);                
    },
    function(error) {  
        console.log("failed to monitor location changes");   
    }
);
```

To start monitoring signifaction location changes use the Geofencing startMonitoringSignificantLocationChanges function. No parameters.

Example:
```bash
Geofencing.stopMonitoringSignificantLocationChanges(
    function(result) { 
        console.log("Stop Location Monitor Success: " + result);                   
    },
    function(error) {  
        console.log("failed to stop monitor location changes");   
    }
);
```

##HOW TO SETUP REGION AND LOCATION NOTIFICATIONS

Of course adding and removing monitored regions would be useless without the ability to receive real time notifications when region boundries are crossed. This setup will allow the JavaScript to receive updates both when the app is running and not running.

Follow these steps to setup region notifications when the app is running:

    Drag and drop the GeofencingHelper.h and GeofencingHelper.m files from the Geofencing folder in Finder to your Plugins folder in XCode.

    Add the following code to the viewDidLoad function in the MainViewController.m file after [super viewDidLoad];


```bash
[[GeofencingHelper sharedGeofencingHelper] setWebView:self.webView];
```

Make sure to import GeofencingHelper.h in the MainViewController.m file.

In your JavaScript add the following code in the same place where you process the documentReady event.

```bash
document.addEventListener("region-update", function(event) {
    var fid = event.regionupdate.fid;
    var status = event.regionupdate.status;
});
```

For location changes add the following code in your JavaScript code in the same place where you process the documentReady event.

```bash
document.addEventListener('location-update', function(event) {
    var new_timestamp = event.locationupdate.new_timestamp;
    var new_speed = event.locationupdate.new_speed;
    var new_course = event.locationupdate.new_course;
    var new_verticalAccuracy = event.locationupdate.new_verticalAccuracy;
    var new_horizontalAccuracy = event.locationupdate.new_horizontalAccuracy;
    var new_altitude = event.locationupdate.new_altitude;
    var new_latitude = event.locationupdate.new_latitude;
    var new_longitude = event.locationupdate.new_longitude;

    var old_timestamp = event.locationupdate.old_timestamp;
    var old_speed = event.locationupdate.old_speed;
    var old_course = event.locationupdate.old_course;
    var old_verticalAccuracy = event.locationupdate.old_verticalAccuracy;
    var old_horizontalAccuracy = event.locationupdate.old_horizontalAccuracy;
    var old_altitude = event.locationupdate.old_altitude;
    var old_latitude = event.locationupdate.old_latitude;
    var old_longitude = event.locationupdate.old_longitude;

    console.log("Location Update Event: " + event); 
});
```


When the app is not running, even in the background, region notifications are saved as they come in. In order to retrieve these pending region notifications follow these instructions.

    Add the following code in the app delegate - (BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions

```bash
if ([[launchOptions allKeys] containsObject:UIApplicationLaunchOptionsLocationKey]) {
    [[GeofencingHelper sharedGeofencingHelper] setDidLaunchForRegionUpdate:YES];
} else {
    [[GeofencingHelper sharedGeofencingHelper] setDidLaunchForRegionUpdate:NO];
}
```

In the JavaScript you will need to use the following code to retrieve these notifications.

```bash
 Geofencing.getPendingRegionUpdates(
        function(result) { 
            var updates = result.pendingupdates;
            $(updates).each(function(index, update){
                var fid = update.fid;
                var status = update.status;
                var timestamp = update.timestamp;
                console.log("fid: " + fid + " status: " + status + " timestamp: " + timestamp);
            });   
        },
        function(error) {   
            alert("failed");
        }
    );
```

