## Unreleased

* Refactor **init()** method. Now init() just initializes our SDK. Authenticate yourself with the new setApiKey(situmUser, situmApiKey) after initializing it.
* Added new method **setDashboardURL()** in SitumSdk. In order to use correctly this method, you should call respectively init(), setDashboardURL() and then setApiKey().
