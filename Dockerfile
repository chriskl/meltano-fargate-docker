ARG MELTANO_IMAGE=meltano/meltano:v1.80.0-python3.8
FROM $MELTANO_IMAGE

WORKDIR /project

# Install chamber
RUN curl -s https://packagecloud.io/install/repositories/segment/chamber/script.deb.sh | /bin/bash \
    && apt-get install -y chamber \
    && apt-get clean

# Install any additional requirements
COPY ./requirements.txt . 
RUN pip install -r requirements.txt

# Install all plugins into the `.meltano` directory
COPY ./meltano.yml . 
RUN meltano install

# Pin `discovery.yml` manifest by copying cached version to project root
RUN cp -n .meltano/cache/discovery.yml . 2>/dev/null || :

# Don't allow changes to containerized project files
ENV MELTANO_PROJECT_READONLY 1

# Copy over remaining project files
COPY . .

ENTRYPOINT []
