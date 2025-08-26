#!/usr/bin/env bash
sudo cp ../kanata/.config/kanata/kanata.kbd /etc/nixos/kanata.kbd
sudo cp ./configuration.nix /etc/nixos/configuration.nix
sudo nixos-rebuild switch --upgrade
