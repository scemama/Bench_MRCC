# Bench_MRCC
Benchmark generator that I use for multi-reference coupled cluster calculations.
It produces CAS-SCF potential energy surfaces with GAMESS, and then runs the
Quantum Package.

# Configuration

Edit the ``config`` file. ``$X={X:-"value"}`` means that if the environment
variable ``X`` is not already defined, it will be defined by ``value``.

# Creating a new benchmark bash script

## List of available environment variables

* ``RUNGMS``     : Command to run GAMESS
* ``TMPDIR``     : Temporary directory for GAMESS calculations
* ``ZVARIABLES`` : changing variables of the z-matrix
* ``GEOMETRY``   : Z-matrix without definition of the changing variables
* ``MULT``       : Spin multiplicity
* ``CHARGE``     : Total charge

## List of variables to define

* ``BASIS`` : Basis set in GAMESS format (CCD,CCT,...)
* ``METHOD`` : argument to be passed to ``create_gamess_input`` : ``HF | MP2 | CAS(n,m)``
* ``DISTANCES`` : Geometries for diatomic separations
* ``EQUILIBRIUM`` : Equilibrium distance 
* ``GEOMETRY`` : z-matrix without the changing variables


## List of functions to define

* ``update_z_variables`` : How to modify the variables of the Z-matrix
* ``iteration`` : What to do at every geometry
* ``initialization`` : What to do for the 1st point

## List of available functions

* ``distance_loop`` : loops over all distances and calls iteration
* ``left_distance_loop`` : loops over all distances before the ``EQUILIBRIUM`` distance
* ``right_distance_loop`` : loops over all distances after the ``EQUILIBRIUM`` distance

## Writing the script

The script should source the ``src/bench_mrcc.sh`` file which contains all
the helpful bash functions. 

