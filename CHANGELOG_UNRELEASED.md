## Unreleased

* Deprecated **init()** method. Instead use initSdk() and setApiKey() respectively.
* Added **initSdk()** method. This method only initializes our SDK.
* Added **setApiKey()** method. Use it to authenticate yourself after initializing our SDK with initSdk().
* Added new method **setDashboardURL()** in SitumSdk. In order to use correctly this method, you should call respectively initSdk(), setDashboardURL() and then setApiKey().
