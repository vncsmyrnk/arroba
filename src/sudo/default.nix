{ runCommand }:

pkg:
runCommand "${pkg.name}-sudo-wrapped" { } ''
    mkdir -p $out/bin

    for binPath in ${pkg}/bin/*; do
      if [ -f "$binPath" ] && [ -x "$binPath" ]; then
        binName=$(basename "$binPath")

        wrapperPath="$out/bin/$binName"
        cat > "$wrapperPath" <<'EOF'
  #!/bin/sh

  # Cross-platform runtime sudo detection
  if [ -x /run/wrappers/bin/sudo ]; then
    SUDO="/run/wrappers/bin/sudo"
  elif [ -x /usr/bin/sudo ]; then
    SUDO="/usr/bin/sudo"
  elif [ -x /bin/sudo ]; then
    SUDO="/bin/sudo"
  else
    SUDO="sudo"
  fi
  EOF

        echo "exec \"\$SUDO\" \"$binPath\" \"\$@\"" >> "$wrapperPath"
        chmod +x "$wrapperPath"
      fi
    done
''
