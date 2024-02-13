{
  outputs = {
    self,
    nixpkgs,
  }: {
    devShells.aarch64-darwin.default = let
      pkgs = import nixpkgs {system = "aarch64-darwin";};
      inherit (pkgs) mkShell elixir_1_16 erlang_25 go;
      inherit (pkgs) stdenv lib inotify-tools darwin;
    in
      mkShell {
        name = "coding-challenges";
        packages =
          [elixir_1_16 erlang_25 go]
          ++ lib.optional stdenv.isLinux [inotify-tools]
          ++ lib.optional stdenv.isDarwin [
            darwin.apple_sdk.frameworks.CoreServices
            darwin.apple_sdk.frameworks.CoreFoundation
          ];
      };
  };
}
