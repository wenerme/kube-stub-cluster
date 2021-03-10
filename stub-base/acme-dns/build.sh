#!/usr/bin/env bash

domains="examole.com examole.org"

out=acme-dns.ignored.json
echo '{}' > $out

for domain in $domains ; do
  fn=$domain.acme-dns.ignored.json
  [ -e "$fn" ] || curl -s -X POST https://auth.acme-dns.io/register | jq > $fn
  jq '."'"$domain"'"=$domain[0]' --slurpfile domain $fn < $out > tmp.json
  mv tmp.json $out
done
rm -f tmp.json
