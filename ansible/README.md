# Ansible Playbooks

This directory contains Ansible playbooks to help setup this dotfiles on new
hosts. The main targets are non-NixOS Linux hosts.

## Files

<dl>
  <dt>vars.yml</dt>
  <dd>
    Contains variables referenced by other playbooks. Edit this file as
    necessary.
  </dd>
  <dt>site.yml</dt>
  <dd>
    The main playbook that imports all other playbooks.
  </dt>
  <dt>proxy.yml</dt>
  <dd>
    Configures proxies.
  </dd>
  <dt>userns.yml</dt>
  <dd>
    Configures Linux user namespaces.
  </dd>
  <dt>nix.yml</dt>
  <dd>
    Installs Nix.
  </dd>
  <dt>dotfiles.yml</dt>
  <dd>
    Downloads and installs this dotfiles. Files will be symlinked into the home
    directory and the Home Manager configuration will be activated.
  </dd>
</dl>
