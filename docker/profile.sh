#Miniconda 4+
#. /opt/conda/etc/profile.d/conda.sh
#conda activate kx

#Miniconda 3
export PATH="$CONDAHOME/bin:$PATH" 
#Already Created
#$CONDAHOME/bin/conda create  -y -n kx python=3 --no-default-packages
echo "Sourcing Kx Conda Profile"
#source activate kx
. activate kx