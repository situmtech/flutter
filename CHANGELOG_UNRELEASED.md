### Fixed

- Fixed a crash triggered under some circumstances when handling internal WebView messages.
  In some cases, the widget could receive events from the underlying WebView after being unmounted,
  causing a null check operator used on a null value exception inside setState().
  The logic has been updated to ensure that message handling is skipped when the widget is no longer
  mounted, preventing this crash.