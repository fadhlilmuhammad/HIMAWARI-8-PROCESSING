#!/bin/bash 



#PBS -q normal
#PBS -l walltime=05:00:00
#PBS -l mem=64GB
#PBS -l ncpus=1
#PBS -l wd
#PBS -lstorage=scratch/v46+gdata/w40+scratch/w40+gdata/hh5+gdata/v46




varg='CTT'
HWV='ACHA_mode_8_cloud_top_temperature'
DDIR='/g/data/v46/lb5963/HIMAWARI/08_V46_SUMM_2021-22/L2/'
WDIR=`pwd`'/'
nr='55'
ODIR=$WDIR'DATA/'
ol='list_L2.txt'

# LIST TOTAL ls $DDIR > $ol

if [ -d $ODIR ]; then
       echo "YES"
else
        mkdir -p $ODIR
fi


while read lst; do


module purge
module use /g/data3/hh5/public/modules
module load conda/analysis3
module load gdal


ifl=$DDIR$lst
echo $ifl
pyf=$varg'_'$nr'.py'

sed -e "14s?XXX?"$ifl"?g"  -e "37s/XXX/"$lst"/g" -e "17s/XXX/"$HWV"/g" -e "46s/XXX/"$HWV"/g" 'FILE/guia.py' > $pyf
#echo $lst
python  $pyf


if [ -f $pyf ]; then
rm  $pyf
else
echo "NOP"
fi


############## GDAL ##################
input=$lst 
file='R_'$lst
out=$varg'_'$lst

if [ -f $file ]; then
rm  $file
else
echo "NOP"
fi

echo '############## STEP 1 ###############################'
echo '############## STEP 1 ###############################'

gdal_translate -a_srs "+proj=geos +lon_0=140.7 +h=35785863 +x_0=0 +y_0=0 +a=6378137 +b=6356752.3 +units=m +no_defs" \
-a_ullr -5500500 -5500500 5500500 5500500  \
-of netCDF  NETCDF:$input:$HWV \
$file    -unscale

data_path=$WDIR
short_file_name=$file

gdal_file_name=NETCDF:"$data_path/$short_file_name":$HWV

# CLM gdalinfo $gdal_file_name

if [ -f $lst ]; then
rm  $lst
else
echo "NOP"
fi



if [ -f $out ]; then
rm  $out
else
echo "NOP"
fi


echo '############## STEP 2 ###############################'
echo '############## STEP 2 ###############################'

gdalwarp -overwrite -r cubic \
-t_srs '+proj=latlong +a=6378137 +b=6356752.3' \
-te 105 -45 160 -7 -tr 0.018 0.018 \
-of netCDF  $gdal_file_name  $ODIR$out  \
-multi -wo "NUM_THREADS=4" -co "COMPRESS=DEFLATE"

if [ -f $file ]; then
rm  $file
else
echo "NOP"
fi



done <$ol
#cat $PBS_NODEFILE
