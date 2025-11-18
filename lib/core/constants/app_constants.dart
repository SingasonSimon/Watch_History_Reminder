class AppConstants {
  // App Info
  static const String appName = 'Watch History Tracker';
  static const String appVersion = '1.0.0';

  // Collections
  static const String videosCollection = 'videos';
  static const String usersCollection = 'users';

  // Storage Paths
  static const String thumbnailsPath = 'thumbnails';

  // Genres
  static const List<String> predefinedGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'Western',
  ];

  // Video Formats
  static const List<String> videoFormats = [
    '.mp4',
    '.avi',
    '.mkv',
    '.mov',
    '.wmv',
    '.flv',
    '.webm',
    '.m4v',
    '.3gp',
  ];

  // VLC Database Paths
  static const Map<String, String> vlcDatabasePaths = {
    'linux': '~/.local/share/vlc/vlc.db',
    'windows': '%APPDATA%\\vlc\\vlc.db',
    'macos': '~/Library/Application Support/org.videolan.vlc/vlc.db',
  };
}

