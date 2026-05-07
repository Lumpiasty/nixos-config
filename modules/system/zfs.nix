{ config, lib, pkgs, modulesPath, ... }:

{
  config = lib.mkIf config.boot.zfs.enabled {
    systemd.services."zfs-arc-limit" = {
      description = "Set ZFS ARC max to 20% of physical RAM";
      # Ensure the module is loaded before we write to /sys
      after = [ "systemd-modules-load.service" ];
      # Run early, but it’s fine if ZFS has already imported; the limit still applies
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.gawk ];
      script = ''
        set -euo pipefail
        # Total RAM in kB
        mem_kb=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
        echo "DEBUG: Total RAM: $mem_kb kB"
        # 20%, in bytes
        arc_max_bytes=$(( mem_kb * 1024 / 100 * 20 ))
        echo "DEBUG: Setting ZFS ARC max to: $arc_max_bytes bytes"
        param="/sys/module/zfs/parameters/zfs_arc_max"
        if [ -w "$param" ]; then
        echo "DEBUG: Writing to $param"
        echo "$arc_max_bytes" > "$param"
        echo "DEBUG: ZFS ARC max successfully set"
        else
        echo "WARN: $param not writable; is the zfs module loaded?" >&2
        exit 0
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}