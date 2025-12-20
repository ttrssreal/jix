{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "mc-monitor";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "itzg";
    repo = "mc-monitor";
    tag = "${finalAttrs.version}";
    hash = "sha256-6koSgAPSeN5WnBhWAdO/s7AhJOG3vELFwycnNuvoRmo=";
  };

  vendorHash = "sha256-WecUZMX85mWc+qv+Mf/ey3dcm3GlwbdA5eC3utF8zEI=";

  ldflags = [
    "-s"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Monitor the status of Minecraft servers and provides Prometheus exporter and Influx line protocol output";
    homepage = "https://github.com/itzg/mc-monitor";
    license = lib.licenses.mit;
    mainProgram = "mc-monitor";
  };
})
