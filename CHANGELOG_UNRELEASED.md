## Unreleased

* Refactor **init()** method, its parameters are now optional. In case you don't declare its paremeters you won't authenticate, just initialize our SDK.
* Added **setApiKey(situmUser, situmApiKey)** method. Use it to authenticate yourself after initializing our SDK with init().
* Added new method **setDashboardURL(url)** in SitumSdk. In order to use correctly this method, you should call respectively init(), setDashboardURL() and then setApiKey(situmUser, situmApiKey).
* Renamed MapViewConfiguration.**baseUrl** to **viewerDomain**.
