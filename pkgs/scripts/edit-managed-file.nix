{
  writeShellApplication,
  vim,
  ...
}:
writeShellApplication {
  name = "edit-managed-file";

  runtimeInputs = [
    vim
  ];

  text = ''
    if [ "$#" -ne 1 ]; then
      >&2 echo "error: usage: $0 <managed-file>"
      exit 1
    fi

    if ! [ -f "$1" ] && ! [ -h "$1" ]; then
      >&2 echo "error: '$1' is not a file or symlink"
      exit 1
    fi

    if ! [ -w "$1" ]; then
      >&2 echo "error: can't edit file '$1' (do you have permissions?)"
      exit 1
    fi

    managed_file="$(realpath --no-symlinks "$1")"
    backup_file="''${managed_file}.orig"

    >&2 echo "editing: $managed_file"

    mv -v "$managed_file" "$backup_file"
    cp -v "$backup_file" "$managed_file"
    chmod -v +w "$managed_file"

    "''${EDITOR:-vim}" "$managed_file"
  '';
}
