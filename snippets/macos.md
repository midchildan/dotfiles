# macOS snippets

> This file contains snippets for macOS environments.
>
> More info: <common.md>

- Display the code signature for a given application:

`codesign --display -vvvv {{path/to/application_file.app}}`

- Display status of loaded kernel extensions:

`kextstat`

- Unload a kernel extension with the given identifier:

`kextunload -b {{unstable.snakeoil.sensor}}`

- Print information about the current launchd user domain:

`launchctl print "gui/$UID"`

- Bootstrap a Launch Agent:

`launchctl bootstrap "gui/$UID" ~/Library/LaunchAgents/{{com.example.launchagent.plist}}`

- Remove a Launch Agent:

`launchctl bootout "gui/$UID/{{com.example.launchagent}}"`

- Fix a stuck App Store download:

`pkill -KILL appstoreagent`
