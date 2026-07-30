{
  description = "PixelForge Canvas Qt Quick and Go MVP";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
            };
          in
          f system pkgs
        );
    in
    {
      packages = forAllSystems (
        system: pkgs:
        let
          qtRuntime = with pkgs.qt6; [
            qtbase
            qtdeclarative
            qtquickcontrols2
            qttools
            qtwayland
          ];
          qmlImportPath = pkgs.lib.concatStringsSep ":" [
            "${pkgs.qt6.qtbase}/lib/qt-6/qml"
            "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml"
            "${pkgs.qt6.qtquickcontrols2}/lib/qt-6/qml"
          ];
        in
        {
          default = pkgs.buildGoModule {
            pname = "pixelforge-canvas";
            version = "0.1.0-mvp";
            src = self;
            vendorHash = null;

            nativeBuildInputs = [ pkgs.makeWrapper ];

            postInstall = ''
              wrapProgram "$out/bin/pixelforge" \
                --prefix PATH : "${pkgs.lib.makeBinPath qtRuntime}" \
                --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qtbase}/lib/qt-6/plugins" \
                --prefix QML2_IMPORT_PATH : "${qmlImportPath}"
            '';
          };
        }
      );

      apps = forAllSystems (system: pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/pixelforge";
        };
      });

      devShells = forAllSystems (system: pkgs: {
        default = pkgs.mkShell {
          packages =
            [
              pkgs.go_1_22
              pkgs.gopls
              pkgs.gotools
              pkgs.pkg-config
            ]
            ++ (with pkgs.qt6; [
              qtbase
              qtdeclarative
              qtquickcontrols2
              qttools
              qtwayland
            ]);

          shellHook = ''
            echo "PixelForge Canvas dev shell"
            echo "Run: make test && make run"
          '';
        };
      });

      formatter = forAllSystems (system: pkgs: pkgs.nixfmt-rfc-style);
    };
}
