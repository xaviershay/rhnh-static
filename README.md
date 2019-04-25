# RHNH Blog

## Development

    bin/dev # Starts dev server on localhost:4000

This is a pretty standard Jekyll site. Keep in progress stuff in `_wip`. Real
posts go in `_posts`. Configuration is in `_config.yml`.

## Deploy

Ensure AWS credentials are in `.env`, then:

    bin/publish

`.env` should look like the following, with credentials that can be generated
frmo IAM Users in AWS Console:

    AWS_ACCESS_KEY_ID=somekey
    AWS_SECRET_ACCESS_KEY=arst

If you get weird syntax errors about ERB, I don't know the root cause but
[here is tracking
issue](https://github.com/laurilehmijoki/s3_website/issues/323). Use
`bin/publish-osx` instead (not 100% sure the OSX bit is relevent.)