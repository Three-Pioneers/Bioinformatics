mkdir -p $CONDA_PREFIX/src $CONDA_PREFIX/opt
cd $CONDA_PREFIX/src

wget -c https://ftp.gnu.org/gnu/gsl/gsl-1.16.tar.gz
tar -zxvf gsl-1.16.tar.gz
cd gsl-1.16
