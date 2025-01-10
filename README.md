# VeryDiff TACAS Artifact

This Docker image aims to allow the reproduction of the experiments from the TACAS 2025 paper *Revisiting Differential Verification: Equivalence Verification with Confidence* as well as the reuse of the tool *VeryDiff*.

It provides a unified environment to run the following tools:

- NeuroDiff
- NNEquiv
- MILPEquiv
- alpha-beta-CROWN
- Marabou
- VeryDiff (ours)

Some of the tools (in particular VeryDiff and MILPEquiv) require Gurobi which is a commercial software product.
Below we describe how to [setup the docker environment and container](#setup) and subsequently how to [run the experiments](#run).
While we support running without Gurobi (via GLPK), this limits some functionalities (e.g. MILPEquiv will not work)

## <a id="setup"></a> 1. Setup

To setup you first require Docker.
Subsequently, we recommend to obtain  Gurobi License.
Afterwards, you can download the image.
This should set you up to run our artifact.

### 1.1. Installing Docker
Installation of Docker is explained in the following resources:
- [Linux](https://docs.docker.com/desktop/install/linux-install/)
- [Apple](https://docs.docker.com/desktop/install/mac-install/)
- [Windows](https://docs.docker.com/desktop/install/windows-install/)

To test if your Docker installation was successful go to a terminal and run `docker run hello-world` this should print a few lines containing (among other things):
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

Note that we can currently only offer a container for x86 systems, i.e. we do *not* support ARM architectures (e.g. Apple Silicon).

### 1.2 Obtaining & Installing a Gurobi License
To obtain a free academic Gurobi **WLS** License:
1. Sign up with Gurobi here using your academic email address: [https://portal.gurobi.com/iam/register/](https://portal.gurobi.com/iam/register/)
2. From your academic institution network go to the [Gurobi User Portal](https://portal.gurobi.com/iam/licenses/request?type=academic)
3. You should see a box titled "WLS Academic": Click on **GENERATE NOW!**
4. Check the box and click on **CONFIRM REQUEST**
5. Head back to the [Gurobi User Portal](https://portal.gurobi.com/iam/licenses/request?type=academic)
6. Click on **Licenses** to get an overview of all your licenses
7. In the table row of the WLS License click on the third item from the right (labeled *Open license within the Web License Manager*)
8. At the corresponding license click on **DOWNLOAD**
9. Enter any application name and description
10. Click **CREATE**
11. Click on **DOWNLOAD**
12. Your browser should download a file named "gurobi.lic". Save this file at a suitable location and save the path. From now on we will assume the file is located at `$HOME/gurobi.lic`

### 1.3 Downloading the Docker Image
We offer multiple approaches to downloading the docker image:
- **From Docker Hub (easiest):**  
Go to your terminal and enter the following commands:
```bash
docker pull samweb/verydiff:artifact
```
- **From DOI (slightly more involved):**
    - Download the TAR file from TODO  
      We assume it is saved in /tmp/verydiff_artifact.tar.gz
    - Import the tar.gz file as Docker Image via:
      ``` bash
      docker load < /tmp/verydiff_artifact.tar.gz
      ```




## <a id="run"></a> 2. Running the Docker Container

### 2.1 Getting Started
To start the Docker Container enter in your terminal:
- **With** Gurobi:  
  ```bash
  docker run  -p 8888:8888 --volume=$HOME/gurobi.lic:/opt/gurobi/gurobi.lic:ro samweb/verydiff:artifact
  ```
- **Without** Gurobi:
  ```bash
  docker run -e NOGUROBI="1" -p 8888:8888 samweb/verydiff:artifact
  ```

To interact with the artifact head to your browser and enter:

[http://127.0.0.1:8888/lab?token=verydiff](http://127.0.0.1:8888/lab?token=verydiff)

You should then see a *Juypter Lab* interface.
Click on **Terminal** to open a Terminal session, this allows you to interact with the Container's terminal.

You have now various options.  
Note that it will take a few seconds for output to show up as Julia first initiates its precompilation...

- To run a few exemplary verification runs enter:  
  ```bash
  ./run_examples.sh
  ```
- To run the experiments for VeryDiff, MILPEquiv, NNEquiv and NeuroDiff:
  ```bash
  ./run_experiments.sh
  ```
  This call:
  - Performs a few warmup runs to trigger precompilation
  - Runs *all* experiments where log files are missing in the directory `experiments_final`

  By default, all experimental logs are available and this call will take approx.
- To run the experiments for Marabou and alpha-beta-CROWN
  ```
  ./run_other_experiments.sh
  ```
  This call runs all Marabou and alpha-beta-CROWN experiments overwriting the previous log files (stored in `./benchmarks_abcrown/marabou_results` for Marabou and in `./benchmarks_abcrown/*.{out,pkl} for alpha-beta-CROWN).
  Note, that this will easily take a few hours or days depending on the machine!
- To reproduce the tables and plots from the paper:
  - We first need to parse the results from Marabou and alpha-beta-CROWN.  
    To this end, execute the two Jupyter Notebooks `./benchmarks_abcrown/Read_abCROWN_logs.ipynb` and `./benchmarks_abcrown/Read_Marabou_logs.ipynb`.  
    These will read the outputs of the two verifiers and save them for later processing
  - We can then reproduce the results by executing any of the notebooks `analysis-new/FINAL_*.ipynb`:  
    These will read the results from `experiments_final` as well as the results from Marabou/ab-CROWN and return the tables and figures presented in the paper.

### 2.2 Playing around
If you want to rerun some of the experiments, you can delete log files the directory `./experiments_final` (or in the limit all subdirectories) and then run the script `run_experiments.sh`. This should repopulate the directory accordingly.
Note that you can also open the log files in Jupyter Lab allowing you to easily check how the results from the original run and the rerun compare.

### 2.3 Rerun
To rerun all experiments we advise against using the Jupyter Lab interface as this would need to be open during the entire execution.
Rerunning all experiments comes at a significant runtime as we have not parallelized our experiments. On a standard machine running all experiments **takes about 2-3 weeks**.
In this case, we advise to use Docker's command line interface and to store the experimental logs on your computer.

The following instructions accompish this:
```
mkdir verydiff_results
docker run -p 8888:8888 --volume=./verydiff_results/logs:/software/VeryDiffExperiments/experiments_final --volume=./verydiff_results/ablogs:/software/VeryDiffExperiments/benchmarks_abcrown --volume=$HOME/gurobi.lic:/opt/gurobi/gurobi.lic:ro samweb/verydiff:artifact /software/VeryDiffExperiments/rerun_all.sh
```

### 2.4 VeryDiff Tool
The version of the VeryDiff tool used in this released is available under DOI [10.5281/zenodo.14627125](https://doi.org/10.5281/zenodo.14627125)