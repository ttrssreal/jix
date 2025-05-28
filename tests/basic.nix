{
  config,
  inputs,
  ...
}:
{
  jix.nixos.basic = {
    profiles.base.enable = true;
    flakeExpose = false;

    users.jess = {
      enable = true;
      uid = 1000;
      extraConfig.password = "password";
    };

    modules = [
      (
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            hello
            coreutils-full
          ];
        }
      )
    ];

    stateVersion = "25.05";
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.test-basic = pkgs.testers.runNixOSTest {
        name = "basic";

        node.specialArgs = { inherit inputs; };
        nodes.machine.imports = config.jix.nixos.basic.modules;

        testScript = ''
          machine.start()
          machine.wait_for_unit("default.target")

          print("meow")
          machine.succeed("ls -la")

          with subtest("The package hello is in the environment"):
            hello_out = machine.succeed("hello")
            assert "Hello, world!" in hello_out, "Package `hello` not installed."

          with subtest("Check jess exists"):
            etc_passwd_out = machine.succeed("cat /etc/passwd")
            assert "jess" in etc_passwd_out, "/etc/passwd doesn't contain jess"
        '';
      };
    };

}
