## Unreleased

* Refactor **init()** method. Now init() does not authenticate users. Instead, use the new setApiKey(situmUser, situmApiKey).
* Added new method **setDashboardURL** in SitumSdk. In order to use correctly this parameter, you should call respectively init(), setDashboardURL() and then setApiKey().
