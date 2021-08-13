#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.requests python3Packages.semver

import json
import requests
import semver

OWNER = "cloudfoundry"
REPO = "cli"
MAJOR = 6


def satisfiesRequirements(tag: str) -> bool:
    version_str = tag[1:] if tag[0] == 'v' else tag
    try:
        ver = semver.VersionInfo.parse(version_str)
    except ValueError:
        return False
    return ver.major == MAJOR and ver.prerelease is None


def get_latest_tag(repo: str, owner: str) -> str:
    r = requests.get(f'https://api.github.com/repos/{owner}/{repo}/tags')
    r.raise_for_status()

    tags = (t.get('name') for t in r.json())
    version_match = next(t for t in tags if satisfiesRequirements(t))
    return version_match


def main():
    rev = get_latest_tag(REPO, OWNER)
    print(rev)


if __name__ == '__main__':
    main()
