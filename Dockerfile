from continuumio/miniconda3

ENV version="2.3.0"

################## METADATA ######################
LABEL base.image="continuumio/miniconda3"
LABEL version="$version"
LABEL software="metagenome-atlas"
LABEL software.version="2"
LABEL about.summary="Three commands to start analysing your metagenome data"
LABEL about.home="https://github.com/metagenome-atlas/atlas"
LABEL about.documentation="https://metagenome-atlas.rtfd.io"
LABEL license="BSD-3"
LABEL about.tags="metagenomics, annotation, snakemake, assembly, genomic-binning, functional-annotation, taxonomic-classifications"

################## MAINTAINER ######################
MAINTAINER Silas Kieser

# Switch back to root for some install

USER root
RUN export LC_ALL=en_US.UTF-8
RUN export LANG=en_US.UTF-8

# setup miniconda
RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge
RUN conda config --set always_yes true

# download atlas
RUN wget https://github.com/metagenome-atlas/atlas/archive/${version}.tar.gz
RUN tar -xzf ${version}.tar.gz && mv atlas-${version} atlas
WORKDIR /atlas


#install metagenome atlas
RUN conda env update -n base --file atlasenv.yml
RUN python setup.py install

# short test
RUN atlas --help
RUN atlas --version

ENV databaseDir="/databases"
ENV WORKING_DIR='/.test/Dryrun'

# Dryrun
RUN atlas init --db-dir $databaseDir --threads 3 -w $WORKING_DIR .test/reads/empty
RUN atlas run all -w $WORKING_DIR --dryrun

# Download databases
RUN atlas download --db-dir $databaseDir
# download conda packages
RUN atlas run all -w $WORKING_DIR --create-envs-only



# Go back to the user
WORKDIR /
USER atlas

CMD atlas --help