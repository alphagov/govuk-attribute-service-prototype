# GOV.UK Attribute Service - Prototype

A prototype to store personal data connected with a GOV.UK account, with consents managed with OAuth tokens issued by the [Account Manager](https://github.com/alphagov/govuk-account-manager-prototype).

## Developer setup

Use [govuk-accounts-docker](https://github.com/alphagov/govuk-accounts-docker) to run this app together with the Account Manager.

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
