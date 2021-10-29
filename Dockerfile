ARG MELTANO_IMAGE=meltano/meltano:v1.86.0
FROM $MELTANO_IMAGE

WORKDIR /project

# Install chamber
ENV chamber_version=2.10.6
RUN wget https://github.com/segmentio/chamber/releases/download/v${chamber_version}/chamber-v${chamber_version}-linux-amd64 -O /bin/chamber \
        && chmod +x /bin/chamber

# Install any additional requirements
COPY ./requirements.txt . 
RUN pip install --upgrade pip \
        && pip install -r requirements.txt

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
