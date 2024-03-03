enum AppRoutes {
  audiobooks('audiobooks', '/audiobooks'),
  audiobook('audiobook', ':index'),
  ;

  final String name;
  final String path;

  const AppRoutes(this.name, this.path);
}
