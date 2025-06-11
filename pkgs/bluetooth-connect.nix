{
  bluez,
  writers,
  python3Packages,
  dmenu,
  lib,
}:
let
  libraries = with python3Packages; [
    xdg-base-dirs
  ];
  bluetoothCtlBin = "${bluez}/bin/bluetoothctl";
in
writers.writePython3Bin "bluetooth-connect" { inherit libraries; } ''
  import re
  import subprocess as subp
  from xdg_base_dirs import xdg_config_home

  config_file = xdg_config_home() / "bluetooth-connect" / "map"
  name_map = {}
  options = None

  lines = open(config_file, "r").readlines()
  for i, line in enumerate(lines):
      try:
          line = line.strip()
          if not line:
              continue
          if re.match("^#", line):
              continue
          key, value = line.split()
          key = bytes(key, "utf-8").decode("unicode_escape").encode("utf-8")
          name_map[key] = value
      except Exception as e:
          print(e)
          options = "Failed to parse config line: {}".format(i+1).encode()

  name_map[b"disconnect"] = None


  # TODO: dwm/dmenu: put font info in one place
  # Issue URL: https://github.com/ttrssreal/jix/issues/37
  p = subp.Popen(["${lib.getExe dmenu}", "-fn", "monospace:size=35"],  # noqa: E501
                 stdout=subp.PIPE,
                 stdin=subp.PIPE,
                 stderr=subp.PIPE)

  options = b"\n".join(name_map.keys()) if not options else options
  stdout_data = p.communicate(input=options)[0]

  selection = stdout_data.removesuffix(b"\n")

  device = name_map[selection]

  bluez_bin = "${bluetoothCtlBin}"  # noqa: E501
  if device:
      subp.run([bluez_bin, "connect", device])
  else:
      subp.run([bluez_bin, "disconnect"])
''
