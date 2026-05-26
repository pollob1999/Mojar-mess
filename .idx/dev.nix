{ pkgs, ... }: {
  channel = "stable-23.11";

  packages = [
    pkgs.flutter
    pkgs.jdk17
    pkgs.unzip
  ];

  env = {};
  idx = {
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart"
    ];

    workspace = {
      onCreate = {
        flutter-create = "flutter create . --overwrite --platforms=android,web --org com.natore.mojarmess";
      };
      onStart = {
        pub-get = "flutter pub get";
      };
    };

    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter" "run" "-d" "web-server" "--web-port" "$PORT" "--web-hostname" "0.0.0.0"];
          manager = "flutter";
        };
        android = {
          command = ["flutter" "run" "-d" "android" "--no-pub"];
          manager = "flutter";
        };
      };
    };
  };
}
