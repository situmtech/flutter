/*import 'package:flutter_test/flutter_test.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding_platform_interface.dart';
import 'package:situm_flutter_wayfinding/situm_flutter_wayfinding_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSitumFlutterWayfindingPlatform
    with MockPlatformInterfaceMixin
    implements SitumFlutterWayfindingPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SitumFlutterWayfindingPlatform initialPlatform = SitumFlutterWayfindingPlatform.instance;

  test('$MethodChannelSitumFlutterWayfinding is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSitumFlutterWayfinding>());
  });

  test('getPlatformVersion', () async {
    SitumFlutterWayfinding situmFlutterWayfindingPlugin = SitumFlutterWayfinding();
    MockSitumFlutterWayfindingPlatform fakePlatform = MockSitumFlutterWayfindingPlatform();
    SitumFlutterWayfindingPlatform.instance = fakePlatform;

    expect(await situmFlutterWayfindingPlugin.getPlatformVersion(), '42');
  });
}
*/