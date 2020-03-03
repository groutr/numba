@rem first configure conda to have more tolerance of network problems, these
@rem numbers are not scientifically chosen, just merely larger than defaults
set CONDA_CONFIG=cmd /C conda config
%CONDA_CONFIG% --write-default
%CONDA_CONFIG% --set remote_connect_timeout_secs 30.15
%CONDA_CONFIG% --set remote_max_retries 10
%CONDA_CONFIG% --set remote_read_timeout_secs 120.2
%CONDA_CONFIG% --set restore_free_channel true
cmd /C conda info
%CONDA_CONFIG% --show

@rem The cmd /C hack circumvents a regression where conda installs a conda.bat
@rem script in non-root environments.
set CONDA_INSTALL=cmd /C conda install -q -y
set PIP_INSTALL=pip install -q

@echo on

@rem Deactivate any environment
call deactivate
@rem Display root environment (for debugging)
conda list
@rem Clean up any left-over from a previous build
conda remove --all -q -y -n %CONDA_ENV%
@rem Scipy, CFFI, jinja2 and IPython are optional dependencies, but exercised in the test suite
conda create -n %CONDA_ENV% -q -y python=%PYTHON% numpy=%NUMPY% cffi pip scipy jinja2 ipython gitpython

call activate %CONDA_ENV%
@rem Install latest llvmlite build
%CONDA_INSTALL% -c numba llvmlite
@rem Install required backports for older Pythons
if %PYTHON% LSS 3.8 (%CONDA_INSTALL% importlib_metadata)
@rem Install dependencies for building the documentation
if "%BUILD_DOC%" == "yes" (%CONDA_INSTALL% sphinx pygments)
if "%BUILD_DOC%" == "yes" (%PIP_INSTALL% sphinx_bootstrap_theme)
@rem Install dependencies for code coverage (codecov.io)
if "%RUN_COVERAGE%" == "yes" (%PIP_INSTALL% codecov)
@rem Install TBB
%CONDA_INSTALL% tbb tbb-devel
if %errorlevel% neq 0 exit /b %errorlevel%

echo "DEBUG ENV:"
echo "-------------------------------------------------------------------------"
conda env export
echo "-------------------------------------------------------------------------"
