class Logger {
  static void info(String msg) {
    // ignore: avoid_print
    print('📝 Situm> Flutter> $msg');
  }

  static void warn(String msg) {
    // ignore: avoid_print
    print('⚠️ Situm> Flutter> $msg');
  }

  static void error(String msg) {
    // ignore: avoid_print
    print('🔴 Situm> Flutter> $msg');
  }
}
