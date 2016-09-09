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

## Writing the script

The script should source the ``src/bench_mrcc.sh`` file which contains all
the helpful bash functions. 

