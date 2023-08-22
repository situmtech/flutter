## Unreleased

* Refactor **init()** method. Now init() does not authenticate users. Instead, use the new setApiKey(situmUser, situmApiKey).
* Added new parameter **dashboardURL** to ConfigurationOptions. In order to use correctly this parameter, you should call respectively init(), setConfiguration() and then  setApiKey().
