git clone git@github.com:ajnisbet/opentopodata.git
cp -r ./opentopodata/docker docker
cp -r ./opentopodata/opentopodata opentopodata-script
cp ./opentopodata/requirements.txt requirements.txt
rm -rf ./opentopodata
mv ./opentopodata-script ./opentopodata

wget -P ./data/etopo1 https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/ice_surface/grid_registered/georeferenced_tiff/ETOPO1_Ice_g_geotiff.zip
unzip ./data/etopo1/ETOPO1_Ice_g_geotiff.zip
rm ./data/etopo1/ETOPO1_Ice_g_geotiff.zip

gdal_translate -a_srs EPSG:4326 ./etopo1/ETOPO1_Ice_g_geotiff.tif ./data/etopo1/ETOPO1.tif
rm ./ETOPO1_Ice_g_geotiff.tif
