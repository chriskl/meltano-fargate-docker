# Meltano ELT

This is a Meltano project template intended for execution by [meltano-fargate-cloudformation](https://github.com/HealthEngineAU/meltano-fargate-docker).

## Environment Setup

First set up `pyenv` if you do not have it installed:

    brew install pyenv
    pyenv install 3.8.9
    pyenv global 3.8.9
    echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.zshrc
    source ~/.zshrc

If you use bash, then use `.bash_profile` instead of `.zshrc`, and if not on a Mac install `pyenv` by another means.

Create a Python 3.8 virtual environment in the cloned project root:

    cd meltano-fargate-docker
    python -m venv .venv
    source .venv/bin/activate
    python -m pip install --upgrade pip

It might be necessary to first install the `psycopg2` binary if you do not have PostgreSQL on your system:

    pip install psycopg2-binary

And then Meltano itself

    pip install -r dev-requirements.txt

Now set up a `.env` file with tap and target settings:

    cp .env.template .env

Or even better, download the production values for the taps and targets you want using Chamber:

    chamber export --format dotenv meltano/tap-salesforce meltano/target-redshift [...] > .env

And follow the tap and target specific configuration steps below.

## Tap-Specific Configuration

### tap-salesforce

* https://medium.com/@bpmmendis94/obtain-access-refresh-tokens-from-salesforce-rest-api-a324fe4ccd9b

## Docker

### Build

    docker build . -t meltano

### Execute as if in production

    docker run -e AWS_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN \
        chamber exec meltano/tap-salesforce meltano/target-redshift -- \
        meltano elt tap-salesforce target-redshift --job_id salesforce-to-redshift

### To jump into the container

    docker run -it -e AWS_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN \
        --entrypoint=/bin/bash meltano -i

### To set up new Chamber secrets

    chamber write meltano/target-redshift TARGET_REDSHIFT_USER meltano
    chamber write meltano/tap-salesforce TAP_SALESFORCE_START_DATE '2017-07-30T00:00:00Z'

For Meltano-wide environmental variables:

    chamber write meltano/ MELTANO_DATABASE_URI postgresql://meltano:xxxxx@hdwu3dw4rcpwf4.c0vpmsgxvmww.ap-southeast-2.rds.amazonaws.com:5432/meltano

Or, use the Parameter Store UI to create a new SecureString parameter.  For the above parameter it would be named `/meltano/target-redshift/target_redshift_user`.

### To grant access to the tap schema

    GRANT USAGE ON SCHEMA tap_salesforce TO GROUP <group>;
    ALTER DEFAULT PRIVILEGES FOR USER meltano IN SCHEMA tap_salesforce GRANT SELECT ON TABLES TO GROUP <group>;
    GRANT SELECT ON ALL TABLES IN SCHEMA tap_saleforce TO GROUP <group>;

