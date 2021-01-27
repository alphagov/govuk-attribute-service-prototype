# GOV.UK Attribute Service - Prototype

A prototype to store personal data connected with a GOV.UK account, with consents managed with OAuth tokens issued by the [Account Manager](https://github.com/alphagov/govuk-account-manager-prototype).

## Developer setup


If you are a GOV.UK developer you can use [govuk-docker](https://github.com/alphagov/govuk-docker) to run this app with the account manager.

For the GOV.UK Account team discovery, we are running the app alongside  [finder-frontend's](https://github.com/alphagov/finder-frontend) transition checker.
Until our prototype is live you will need [a branch](https://github.com/alphagov/govuk-docker/tree/enable-account-finder-frontend) of govuk-docker `enable-account-finder-frontend`, which has the required environment variables to spin up the service.

If you are on a mac, running finder-frontend will spin up a large number of apps and require many resources.
Ensure you have read [the installation guide](https://github.com/alphagov/govuk-docker/blob/master/docs/installation.md#docker-settings) about increasing system resources to docker, or you may see errors transitioning between apps.

We also maintain [govuk-accounts-docker](https://github.com/alphagov/govuk-accounts-docker) which is intended to help government services outside GOV.UK set up a development environment.

### Running the tests

You don't need govuk-accounts-docker to run the tests, a local postgres database is enough:

```
docker run --rm -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=db -p 5432:5432 postgres:13
```

Set up your environment and create the database tables:

```
export TEST_DATABASE_URL="postgresql://postgres:postgres@127.0.0.1/db"
bundle exec rake db:migrate RAILS_ENV=test
```

Then you can run the tests with:

```
bundle exec rake
```

## Deployment to GOV.UK via concourse

Every commit to main is deployed to GOV.UK PaaS by [this concourse pipeline](https://cd.gds-reliability.engineering/teams/govuk-tools/pipelines/govuk-attribute-service-prototype), which is configured in [concourse/pipeline.yml](/concourse/pipeline.yml).

You will need to be logged into the GDS VPN to access concourse.

The concourse pipeline has credentials for the govuk-accounts-developers user in GOV.UK PaaS. This user has the SpaceDeveloper role, so it can `cf push` the application.

### Secrets

Secrets are defined via the [gds-cli](https://github.com/alphagov/gds-cli) and Concourse secrets manager.

You can view live secrets with an authenticated cloud foundry command:

```
cf env govuk-attribute-service
```

Adding or updating a secret can be done with Concourse secrets manager and the [GDS cli](https://docs.publishing.service.gov.uk/manual/get-started.html#3-install-gds-tooling).

```
gds cd secrets add cd-govuk-tools govuk-attribute-service-prototype/SECRET_NAME your_secret_value
```

To remove a secret:

```
gds cd secrets rm cd-govuk-tools govuk-attribute-service-prototype/SECRET_NAME
```

You would also need to unset it from the PaaS environment. Which you can do with this command:

```
cf unset-env govuk-attribute-service SECRET_NAME
```
