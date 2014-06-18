// test
// cordova.define("com.siteforum.plugins.geofencing.Geofencing", function(require, exports, module) {var exec = require('cordova/exec');

var exec = require('cordova/exec');

/**
 * Constructor
 */
function Geofencing() {}

Geofencing.prototype.addRegion = function(success, fail, params) {
  exec(success, fail, "Geofencing", "addRegion", [params || {}]);
};

Geofencing.prototype.removeRegion = function(success, fail, params) {
  exec(success, fail, "Geofencing", "removeRegion", [params || {}]);
};
               
Geofencing.prototype.setHost = function(success, fail, params) {
   exec(success, fail, "Geofencing", "setHost", [params || {}]);
};
               
Geofencing.prototype.setToken = function(success, fail, params) {
   exec(success, fail, "Geofencing", "setToken", [params || {}]);
};

/*
Params:
NONE
*/
Geofencing.prototype.getWatchedRegionIds = function(success, fail) {
  exec(success, fail, "Geofencing", "getWatchedRegionIds", []);
};

/*
Params:
NONE
*/
Geofencing.prototype.getPendingRegionUpdates = function(success, fail) {
  exec(success, fail, "Geofencing", "getPendingRegionUpdates", []);
};

/*
Params:
NONE
*/
Geofencing.prototype.startMonitoringSignificantLocationChanges = function(success, fail) {
  exec(success, fail, "Geofencing", "startMonitoringSignificantLocationChanges", []);
};

/*
Params:
NONE
*/
Geofencing.prototype.stopMonitoringSignificantLocationChanges = function(success, fail) {
  exec(success, fail, "Geofencing", "stopMonitoringSignificantLocationChanges", []);
};

/*
This is used so the JavaScript can be updated when a region is entered or exited
*/
Geofencing.prototype.regionMonitorUpdate = function(regionupdate) {
        console.log("regionMonitorUpdate: " + regionupdate);
        var ev = document.createEvent('HTMLEvents');
        ev.regionupdate = regionupdate;
        ev.initEvent('region-update', true, true, arguments);
        document.dispatchEvent(ev);
};

/*
This is used so the JavaScript can be updated when a significant change has occured
*/
Geofencing.prototype.locationMonitorUpdate = function(locationupdate) {
        console.log("locationMonitorUpdate: " + locationupdate);
        var ev = document.createEvent('HTMLEvents');
        ev.locationupdate = locationupdate;
        ev.initEvent('location-update', true, true, arguments);
        document.dispatchEvent(ev);
};


// exports
var Geofencing = new Geofencing();
module.exports = Geofencing;
// });
