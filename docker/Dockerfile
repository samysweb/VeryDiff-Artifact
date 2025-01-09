# Tag from 19th of August 2024
FROM quay.io/jupyter/minimal-notebook:2024-08-19
    #ubuntu-22.04

FROM quay.io/jupyter/base-notebook:2024-08-19
USER root
COPY --from=0 /opt/setup-scripts/ /opt/setup-scripts
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # Common useful utilities
    curl \
    git \
    nano-tiny \
    tzdata \
    unzip \
    make \
    g++ \
    build-essential &&\
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Installing python packages
USER ${NB_UID}
RUN conda create -y --name verydiff python=3.8
RUN conda run -n verydiff pip install numpy==1.22.4 &&\
    conda install -n verydiff -y onnx==1.12 onnxruntime==1.18.0 &&\
    conda install -n verydiff -y -c anaconda ipykernel
USER root

RUN mkdir -p /data && chmod 777 /data && mkdir -p /software && chmod 777 /software

# Julia dependencies
# install Julia packages in /opt/julia instead of ${HOME}
ENV JULIA_DEPOT_PATH=/opt/julia \
    JULIA_PKGDIR=/opt/julia

# Setup Julia
COPY ./setup_julia.py /opt/setup-scripts/setup_julia.py
RUN chmod +x /opt/setup-scripts/setup_julia.py
RUN /opt/setup-scripts/setup_julia.py

USER ${NB_UID}
# Setup IJulia kernel & other packages
RUN /opt/setup-scripts/setup-julia-packages.bash

# Download & Install VeryDiff, VeryDiffExperiments and NeuroDiff
ENV VERYDIFF_VERSION=a896894
RUN cd /software &&\
    git clone https://github.com/samysweb/VeryDiff-Release.git VeryDiff &&\
    cd VeryDiff &&\
    git checkout $VERYDIFF_VERSION &&\
    julia --project=. -e 'using Pkg;Pkg.instantiate();Pkg.build();'

ENV NEURODIFF_VERSION=d05fd14
ENV NUM_THREADS=0
RUN cd /software &&\
    git clone https://github.com/pauls658/NeuroDiff-ASE2020-Artifact.git NeuroDiff &&\
    cd NeuroDiff &&\
    git checkout $NEURODIFF_VERSION &&\
    bash install_OpenBLAS.sh

# NeuroDiff is slightly broken so we need to move the definition of pthread_mutex_t lock;
COPY ./split.c /software/NeuroDiff/DiffNN-Code/split.c
COPY ./split.h /software/NeuroDiff/DiffNN-Code/split.h

# We measure Single Threadded Performance
ENV NUM_THREADS=-1
RUN cd /software/NeuroDiff &&\
    source set_paths.sh &&\
    cd DiffNN-Code &&\
    CFLAGS=-DMAX_THREAD=$NUM_THREADS make clean lineqall extravarssym all

# Install Marabou -> installs ~/.local/bin/Marabou
RUN pip install maraboupy==2.0.0

# Install alpha-beta-CROWN
ENV ABCROWN_VERSION=dc32df038440a9726e97547b88f9913743773e7f
RUN cd /software &&\
    git clone --recursive https://github.com/Verified-Intelligence/alpha-beta-CROWN.git abCROWN
RUN cd /software/abCROWN &&\
    conda env create -f complete_verifier/environment.yaml --name alpha-beta-crown

ENV VERYDIFFEXP_VERSION=f39b79be4
RUN cd /software &&\
    git clone https://gitlab.kit.edu/paul.teuber/verydiff-experiments.git VeryDiffExperiments &&\
    cd VeryDiffExperiments &&\
    git checkout $VERYDIFFEXP_VERSION &&\
    julia --project=. -e 'using Pkg;Pkg.instantiate();Pkg.develop(path="./../VeryDiff")'
RUN cd /software/VeryDiffExperiments &&\
    julia --project=. -e 'using Pkg;Pkg.build();'

# USER root

ENV JULIA_PROJECT=/software/VeryDiffExperiments
ENV LD_LIBRARY_PATH=/software/NeuroDiff/DiffNN-Code/lib:

# USER ${NB_UID}
# # Install Julia verydiff Kernel and trigger precompilation as explicitly as possible
# RUN julia -E 'using Pkg;Pkg.add(["IJulia","Plots"]);using IJulia;installkernel("Julia VeryDiff", "--depwarn=no");Pkg.precompile()'
# # Install Python verydiff Kernel
# RUN conda run -n verydiff python -m ipykernel install --user --name=Python_verydiff


WORKDIR /software/VeryDiffExperiments
USER root
RUN chmod -R 777 /software/VeryDiffExperiments
USER ${NB_UID}
CMD ["start-notebook.py", "--NotebookApp.token='verydiff'"]