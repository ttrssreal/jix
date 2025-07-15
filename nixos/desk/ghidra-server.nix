# https://git.lain.faith/haskal/dragnpkgs/src/commit/8a7924eec1d5/modules/ghidra-server/default.nix
{
  lib,
  pkgs,
  ...
}:
{
  users = {
    groups.ghidra = { };
    users.ghidra = {
      isSystemUser = true;
      home = "/var/lib/ghidra-server";
      group = "ghidra";
      packages = [
        pkgs.ghidra
        pkgs.openjdk21_headless
      ];
    };
  };

  systemd.services."ghidra-server" =
    let
      ghidraJavaOpts = [
        "-Djava.net.preferIPv4Stack=true"
        "-Djava.io.tmpdir=/tmp"
        "-Djna.tmpdir=/tmp"
        "-Dghidra.tls.server.protocols=TLSv1.2;TLSv1.3"
        "-Ddb.buffers.DataBuffer.compressedOutput=true"
        "-Xms396m"
        "-Xmx768m"
      ];
      ghidraHome = "${pkgs.ghidra}/lib/ghidra";
      ghidraClasspath =
        let
          input = lib.readFile "${ghidraHome}/Ghidra/Features/GhidraServer/data/classpath.frag";
          inputSplit = lib.split "[^\n]*ghidra_home.([^\n]*)\n" input;
          paths = map lib.head (lib.filter lib.isList inputSplit);
        in
        ghidraHome + (lib.concatStringsSep (":" + ghidraHome) paths);
      ghidraMainClass = "ghidra.server.remote.GhidraServer";
      ghidraArgs = "-a0 -p${toString 13100} -ip 192.168.200.71 /var/lib/ghidra-server/repositories";
    in
    {
      description = "Ghidra server";
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = lib.concatStringsSep " " (
          lib.flatten [
            "${pkgs.openjdk21_headless}/bin/java"
            ghidraJavaOpts
            "-classpath"
            ghidraClasspath
            ghidraMainClass
            ghidraArgs
          ]
        );
        WorkingDirectory = "/var/lib/ghidra-server";
        Environment = "GHIDRA_HOME=${ghidraHome}";
        User = "ghidra";
        Group = "ghidra";
        SuccessExitStatus = 143;

        # use StateDirectory to create home dir and additional needed dirs with overridden
        # permissions when the unit starts
        # this is needed because we'd like the group (ghidra) to have write access to the
        # directories here, particularly ~admin
        StateDirectory = "ghidra-server ghidra-server/repositories ghidra-server/repositories/~admin";
        StateDirectoryMode = "0770";

        PrivateTmp = true;
        NoNewPrivileges = true;
      };
      wantedBy = [ "multi-user.target" ];
    };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "ghidra-svrAdmin" ''
      exec ${pkgs.openjdk21_headless}/bin/java \
        -cp ${pkgs.ghidra}/lib/ghidra/Ghidra/Framework/Utility/lib/Utility.jar \
        -Djava.system.class.loader=ghidra.GhidraClassLoader \
        -Dfile.encoding=UTF8 \
        -Duser.country=US -Duser.language=en -Duser.variant= \
        -Xshare:off ghidra.Ghidra ghidra.server.ServerAdmin \
        ${pkgs.writeText "server.conf" "ghidra.repositories.dir=/var/lib/ghidra-server/repositories"} \
        "$@"
    '')
  ];

  # jess:password
}
