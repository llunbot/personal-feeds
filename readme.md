# Personal feeds site

This is an empty repo with feeds source for feeds fetcher to read and pull content and build static feeds site

## Hosting

The built site is published to the `contents` branch and served by GitHub Pages at <https://llunbot.github.io/personal-feeds/>, with no custom domain set on Pages. <https://feeds.llun.dev/> is an AWS CloudFront distribution whose origin is `llunbot.github.io` with origin path `/personal-feeds`, so traffic to the site shows up in CloudFront's reports. The workflow sets `siteUrl` instead of `customDomain`, which keeps the site at the root path without writing a `CNAME` file.
