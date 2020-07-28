# Common snippets

> This file contains command examples used by our snippet expansion widget for
> zsh. It's triggered by pressing `^X^J` in insert mode, and the placeholders
> can be replaced by pressing `^J` also in insert mode.
>
> The format of this file is derived from tldr-pages.
> More info: <https://github.com/tldr-pages/tldr/blob/master/contributing-guides/style-guide.md>

- Generate an Autoconf configure script:

`autoreconf -if`

- Manage ignore files for a local copy of a git repository:

`git exec $EDITOR .git/info/exclude`

- Serve the current directory over HTTP:

`python3 -m http.server {{8000}} --bind {{127.0.0.1}}`

- Start an httpbin server:

`gunicorn -b {{localhost}}:{{8080}} httpbin:app -k gevent`

- Start an OpenSSL test HTTP server:

`openssl s_server -accept {{4443}} -www`

- Show diagnostic information for remote TLS servers:

`openssl s_client -connect {{localhost:443}} < /dev/null`

- Generate a random string of length n:

`openssl rand -base64 {{n}} | head -c{{n}}`

- Shorten a GitHub URL:

`curl -i https://git.io -F 'url={{url}}' -F 'code={{code}}'`

- Watch an ASCII animation of Star Wars:

`nc towel.blinkenlights.nl 23`
