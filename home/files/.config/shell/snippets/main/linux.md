# Linux snippets

> This file contains snippets for Linux environments.
>
> More info: <common.md>

- Create a transient systemd user timer unit:

`systemd-run -u {{name}} --user --on-calendar="$(date -d '{{tomorrow 7am}}' +'%F %T')" --timer-property=AccuracySec=1us -d --service-type=oneshot {{command}}`

- Extract a DEB file:

`dpkg-deb -x {{target.deb}} {{.}}`

- Extract an RPM file:

`rpm2cpio {{target.rpm}} | cpio -idv`
