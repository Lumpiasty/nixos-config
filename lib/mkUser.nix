{ lib }:
condition: user:

lib.mkIf condition (import user)
