# GOV.UK Attribute Service - Prototype

A prototype to store personal data connected with a GOV.UK account, with consents managed with OAuth tokens issued by the [Account Manager](https://github.com/alphagov/govuk-account-manager-prototype).

## Developer setup

If you are a GOV.UK developer you can use [govuk-docker](https://github.com/alphagov/govuk-docker) to run this app with the account manager.

For the GOV.UK Account team discovery, we are running the app alongside  [finder-frontend's](https://github.com/alphagov/finder-frontend) transition checker.
Until our prototype is live you will need [a branch](https://github.com/alphagov/govuk-docker/tree/enable-account-finder-frontend) of govuk-docker `enable-account-finder-frontend`, which has the required environment variables to spin up the service.

If you are on a mac, running finder-frontend will spin up a large number of apps and require many resources.
Ensure you have read [the installation guide](https://github.com/alphagov/govuk-docker/blob/master/docs/installation.md#docker-settings) about increasing system resources to docker, or you may see errors transitioning between apps.

We also maintain [govuk-accounts-docker](https://github.com/alphagov/govuk-accounts-docker) which is intended to help government services outside GOV.UK set up a development environment.
