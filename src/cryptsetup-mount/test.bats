#!/usr/bin/env bats

setup() {
  export DATA_PATH="$BATS_TEST_TMPDIR/data"
  export CONFIG_PATH="$BATS_TEST_TMPDIR/config"
  export MAPPER_PATH="$BATS_TEST_TMPDIR/mapper"
  mkdir -p "$DATA_PATH" "$CONFIG_PATH" "$MAPPER_PATH"

  export MOCK_BIN_DIR="$BATS_TEST_TMPDIR/mock_bin"
  mkdir -p "$MOCK_BIN_DIR"
  export PATH="$MOCK_BIN_DIR:$PATH"
  export UTILITIES_CRYPTSETUP_PREFIX="utilities-"

  echo -e '#!/bin/sh\necho "/tmp/my-mount"' >"$MOCK_BIN_DIR/jq"
  echo -e '#!/bin/sh\ncat' >"$MOCK_BIN_DIR/envsubst"

  cat <<'EOF' >"$MOCK_BIN_DIR/cryptsetup"
#!/bin/sh
echo "$@" >> "$BATS_TEST_TMPDIR/cryptsetup_args.log"
exit 0
EOF

  cat <<'EOF' >"$MOCK_BIN_DIR/mount"
#!/bin/sh
echo "$@" >> "$BATS_TEST_TMPDIR/mount_args.log"
exit 0
EOF

  cat <<'EOF' >"$MOCK_BIN_DIR/mktemp"
#!/bin/sh
echo "$BATS_TEST_TMPDIR/mock-temp-dir"
EOF

  chmod +x "$MOCK_BIN_DIR"/*
}

@test "fails when container file is missing" {
  run bash "$BATS_TEST_DIRNAME/script.sh" "my-container"

  [[ "$status" -eq 1 ]]
  [[ "$output" = "container file not found." ]]
}

@test "succeeds with temp dir when container config is missing" {
  touch "$DATA_PATH/my-container.img"

  # mock jq to return error so mktemp is used
  echo -e '#!/bin/sh\nexit 1' >"$MOCK_BIN_DIR/jq"

  run bash "$BATS_TEST_DIRNAME/script.sh" "my-container"

  [[ "$status" -eq 0 ]]
  mount_args=$(cat "$BATS_TEST_TMPDIR/mount_args.log")
  [[ "$mount_args" = "$MAPPER_PATH/utilities-my-container $BATS_TEST_TMPDIR/mock-temp-dir" ]]
}

@test "succeeds with temp dir when mountpoint is missing from config" {
  touch "$DATA_PATH/my-container.img"
  echo '{"other": "value"}' >"$CONFIG_PATH/my-container.json"

  # mock jq to return error so mktemp is used
  echo -e '#!/bin/sh\nexit 1' >"$MOCK_BIN_DIR/jq"

  run bash "$BATS_TEST_DIRNAME/script.sh" "my-container"

  [[ "$status" -eq 0 ]]
  mount_args=$(cat "$BATS_TEST_TMPDIR/mount_args.log")
  [[ "$mount_args" = "$MAPPER_PATH/utilities-my-container $BATS_TEST_TMPDIR/mock-temp-dir" ]]
}

@test "fails when cryptsetup open fails" {
  touch "$DATA_PATH/my-container.img"
  echo '{"mountpoint": "/tmp/my-mount"}' >"$CONFIG_PATH/my-container.json"

  cat <<'EOF' >"$MOCK_BIN_DIR/cryptsetup"
#!/bin/sh
exit 1
EOF

  run bash "$BATS_TEST_DIRNAME/script.sh" "my-container"

  [[ "$status" -eq 1 ]]
}

@test "closes cryptsetup if mount fails" {
  touch "$DATA_PATH/my-container.img"
  echo '{"mountpoint": "/tmp/my-mount"}' >"$CONFIG_PATH/my-container.json"

  cat <<'EOF' >"$MOCK_BIN_DIR/mount"
#!/bin/sh
exit 1
EOF

  run bash "$BATS_TEST_DIRNAME/script.sh" "my-container"

  [[ "$status" -eq 1 ]]
  cryptsetup_args=$(cat "$BATS_TEST_TMPDIR/cryptsetup_args.log")
  [[ "$cryptsetup_args" = "open $DATA_PATH/my-container.img utilities-my-container
close utilities-my-container" ]]
}

@test "successfully mounts the container and passes correct arguments" {
  touch "$DATA_PATH/my-container.img"
  echo '{"mountpoint": "/tmp/my-mount"}' >"$CONFIG_PATH/my-container.json"

  run bash "$BATS_TEST_DIRNAME/script.sh" "my-container"

  [[ "$status" -eq 0 ]]

  cryptsetup_args=$(cat "$BATS_TEST_TMPDIR/cryptsetup_args.log")
  [[ "$cryptsetup_args" = "open $DATA_PATH/my-container.img utilities-my-container" ]]

  mount_args=$(cat "$BATS_TEST_TMPDIR/mount_args.log")
  [[ "$mount_args" = "$MAPPER_PATH/utilities-my-container /tmp/my-mount" ]]
}
