# Common snippets

> This file contains command examples used by the snippet expansion widget for
> zsh included in this dotfiles. It's triggered by pressing `^X^J` in insert
> mode, and the placeholders can be replaced by pressing `^J` also in insert
> mode.
>
> The format of this file is derived from tldr-pages.
> More info: <https://github.com/tldr-pages/tldr/blob/master/contributing-guides/style-guide.md>
>
> Some snippets may include zsh-specific syntax.

- Run Ansible playbook on localhost:

`ansible-playbook {{site.yml}} -i localhost, -e ansible_connection=local`

- Generate an Autoconf configure script:

`autoreconf -if`

- Create an archive whose format matches the extension of the target filename:

`bsdtar acf {{target.zip}} {{files...}}`

- Create an archive, but cd to the specified directory before doing it:

`bsdtar -C {{dir}} acf {{target.tar.gz}} {{files...}}`

- Send an HTTP request to dev.example.com, but treat it as example.com:

`curl --resolve "{{example.com}}:443:$(dig +short {{dev.example.com}} A)" 'https://{{example.com}}'`

- Attach a bearer token to an HTTP request:

`curl '{{https://example.com/}}' -H "Authorization: Bearer {{$token}}"`

- Send a DNS-over-HTTPS request:

`curl -sSL -H 'application/dns-json' '{{https://cloudflare-dns.com/dns-query}}?name={{example.com}}&type={{A}}'`

- Lookup the manpage for a specific version of tmux:

`curl -sSfL https://raw.githubusercontent.com/tmux/tmux/{{2.8}}/tmux.1 | nroff -mdoc | less`

- Stop all Docker containers:

`docker container ls -aq | xargs docker container stop`

- Remove all Docker containers:

`docker container ls -aq | xargs docker container rm`

- Run a Docker command without messing up ctrl-p key presses:

`docker {{run}} --detach-keys ctrl-q,d {{args...}}`

- Count the number of files in a directory:

`find {{path/to/directory}} -type f -printf . | wc -c`

- Add files to the git staging area, but leave their contents out:

`git add --intent-to-add {{flake.nix}}`

- Delete merged git branches:

`git for-each-ref --format='%(refname:short)' --merged=HEAD refs/heads/ | grep -v "^$(git rev-parse --abbrev-ref HEAD)\$" | grep -Ev '{{^main|master|dev(elop(ment){0,1}){0,1}$}}' | xargs git branch -d`

- Tell git whether it should assume that certain files are unchaged:

`git update-index --{{no-}}assume-unchanged {{flake.nix}}`

- Manage ignore files for a local copy of a git repository:

`git exec $EDITOR .git/info/exclude`

- Trigger a rebuild of GitHub Pages for the specified repository:

`gh api -X POST repos/{{:owner/:repo}}/pages/builds`

- List open GitHub PRs created by me today:

`gh search prs --author '@me' --state open --archived=false --created "$(date +%Y-%m-%d)" --json url -q '.[].url'`

- Start gpg-agent. Try this when Git fails to sign commits:

`gpg-connect-agent /bye`

- Reload gpg-agent:

`gpg-connect-agent reloadagent /bye`

- Try this when SSH authentication with gpg-agent hangs:

`gpg-connect-agent updatestartuptty /bye`

- List commands for gpg-agent:

`gpg-connect-agent help /bye`

- Start an httpbin server:

`gunicorn -b {{localhost}}:{{8080}} httpbin:app -k gevent`

- Send terminfo files for the kitty terminal to an SSH server:

`kitty +kitten ssh {{server_name}}`

- Watch an ASCII animation of Star Wars:

`nc towel.blinkenlights.nl 23`

- Start an OpenSSL test HTTP server:

`openssl s_server -accept {{4443}} -www`

- Show diagnostic information for remote TLS servers:

`openssl s_client -connect {{localhost:443}} -servername {{domain.example}} < /dev/null`

- Generate a random string of length n:

`openssl rand -base64 {{n}} | head -c{{n}}`

- Serve the current directory over HTTP:

`python3 -m http.server {{8000}} --bind {{127.0.0.1}}`

- Format JSON:

`python3 -m json.tool {{input.json}}`

- Update GitHub SSH host keys in `~/.ssh/known_hosts`:

`ssh-keygen -R github.com; curl -L https://api.github.com/meta | jq -r '.ssh_keys | .[]' | sed -e 's/^/github.com /' | tee -a ~/.ssh/known_hosts`

- Create n additional split tmux windows:

`repeat {{n}}; do tmux split-window; tmux select-layout main-horizontal; done`

- Expand an embedded Ruby template:

`erb -T - {{template.txt.erb}}`

- Show the ink level of an USB printer:

`sudo ink -p usb`

- Show the ink level of a Canon BJNP printer:

`sudo ink -p bjnp`

- Decode URL-encoded string from stdin:

`while read; do : "${REPLY//\%/\\x}"; printf '%b\n' "${_//+/ }"; done`
