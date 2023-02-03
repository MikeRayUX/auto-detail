#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /auto-detail-app/tmp/pids/server.pid

# fixes pg:connection bad which seems to be a windows specific issue.
cp /etc/hosts /etc/hosts.new && \
sed -i 's/::1\tlocalhost ip6-localhost ip6-loopback/::1 ip6-localhost ip6-loopback/' /etc/hosts.new && \
cp -f /etc/hosts.new /etc/hosts

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
