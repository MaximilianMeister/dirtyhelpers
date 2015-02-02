#!/bin/bash

zypper --non-interactive --gpg-auto-import-keys --no-gpg-checks refresh -f
zypper --non-interactive up -l
zypper --non-interactive --gpg-auto-import-keys --no-gpg-checks install git sqlite3-devel gcc make ruby-devel libxml2-devel
cd ~
git clone https://github.com/MaximilianMeister/nailed.git
cd ~/nailed
bundle.ruby2.1 install
