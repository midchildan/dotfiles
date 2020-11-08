# bpftrace wrapper package with lower priority value than bcc
#
# Avoided overriding bpftrace directly to avoid recompilation.

{ linuxPackages, symlinkJoin }:

let inherit (linuxPackages) bcc bpftrace;
in symlinkJoin {
  name = bpftrace.name;

  paths = [ bpftrace ];
  preferLocalBuild = true;
  passthru.unwrapped = bpftrace;

  meta = {
    priority = (bcc.meta.priority or 0) + 1;
    inherit (bpftrace.meta) description homepage license;
  };
}
