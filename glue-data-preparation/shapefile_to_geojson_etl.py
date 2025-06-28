import sys
import json
import uuid
import tempfile
import shutil
import os
from datetime import datetime
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import boto3
import geopandas as gpd
from shapely.geometry import mapping
from shapely.validation import make_valid
from shapely import wkt
import pyproj

# Initialize contexts and job
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Configuration
source_bucket = "map-appraiser-data-raw-gis"
target_bucket = "map-appraiser-data-knowledge-base"
target_folder = "gis-geojson"

# S3 client for listing and downloading files
s3_client = boto3.client('s3')

def list_shapefile_folders():
    """List all folders containing shapefiles in the source bucket"""
    paginator = s3_client.get_paginator('list_objects_v2')
    page_iterator = paginator.paginate(
        Bucket=source_bucket,
        Prefix='',
        Delimiter='/'
    )
    
    folders = []
    for page in page_iterator:
        if 'CommonPrefixes' in page:
            for prefix in page['CommonPrefixes']:
                folder = prefix['Prefix'].rstrip('/')
                folders.append(folder)
    
    return sorted(folders)

def find_shapefiles(folder):
    """Find all .shp files within a folder (checking two levels deep)"""
    shapefiles = []
    
    paginator = s3_client.get_paginator('list_objects_v2')
    pages = paginator.paginate(
        Bucket=source_bucket,
        Prefix=f"{folder}/"
    )
    
    for page in pages:
        if 'Contents' in page:
            for obj in page['Contents']:
                if obj['Key'].lower().endswith('.shp'):
                    shapefiles.append(obj['Key'])
    
    return shapefiles

def download_shapefile_components(shp_key, temp_dir):
    """Download all components of a shapefile (.shp, .shx, .dbf, .prj, etc.)"""
    base_path = shp_key[:-4]  # Remove .shp extension
    extensions = ['.shp', '.shx', '.dbf', '.prj', '.cpg', '.sbn', '.sbx', '.fbn', '.fbx', '.ain', '.aih', '.atx', '.ixs', '.mxs', '.qix', '.shp.xml']
    
    local_files = []
    for ext in extensions:
        try:
            s3_key = base_path + ext
            local_path = os.path.join(temp_dir, os.path.basename(s3_key))
            
            # Try both lowercase and uppercase extensions
            try:
                s3_client.download_file(source_bucket, s3_key, local_path)
                local_files.append(local_path)
                print(f"Downloaded: {s3_key}")
            except:
                # Try uppercase
                s3_key_upper = base_path + ext.upper()
                try:
                    s3_client.download_file(source_bucket, s3_key_upper, local_path)
                    local_files.append(local_path)
                    print(f"Downloaded: {s3_key_upper}")
                except:
                    # Extension doesn't exist, which is fine for optional files
                    pass
        except Exception as e:
            print(f"Could not download {ext} file: {str(e)}")
    
    return local_files

def validate_and_fix_geometry(geom):
    """Validate and fix geometry issues"""
    if geom is None or geom.is_empty:
        return None
    
    try:
        # Check if geometry is valid
        if not geom.is_valid:
            print(f"Invalid geometry detected: {geom.is_valid_reason if hasattr(geom, 'is_valid_reason') else 'Unknown reason'}")
            # Try to fix the geometry
            geom = make_valid(geom)
            
            # If still invalid or empty after fixing, return None
            if not geom.is_valid or geom.is_empty:
                print("Could not fix geometry, skipping feature")
                return None
                
        return geom
    except Exception as e:
        print(f"Error validating geometry: {str(e)}")
        return None

def round_coordinates(geom, decimals=6):
    """Round coordinates to specified decimal places with better error handling"""
    if geom is None:
        return None
        
    try:
        from shapely.ops import transform
        from shapely.geometry import Point, LineString, Polygon
        
        def round_coords(x, y, z=None):
            if z is not None:
                return (round(x, decimals), round(y, decimals), round(z, decimals))
            else:
                return (round(x, decimals), round(y, decimals))
        
        return transform(round_coords, geom)
    except Exception as e:
        print(f"Error rounding coordinates: {str(e)}")
        # Fallback: return original geometry
        return geom

def process_shapefile_to_geojson(shp_key, folder_name):
    """Process a single shapefile and write each feature as a GeoJSON file"""
    print(f"Processing shapefile: {shp_key}")
    
    # Create temporary directory for shapefile components
    temp_dir = tempfile.mkdtemp()
    processed_count = 0
    
    try:
        # Download all shapefile components
        local_files = download_shapefile_components(shp_key, temp_dir)
        
        if not local_files:
            print(f"No files downloaded for {shp_key}")
            return 0
        
        # Find the .shp file
        shp_file = None
        for f in local_files:
            if f.lower().endswith('.shp'):
                shp_file = f
                break
        
        if not shp_file:
            print(f"No .shp file found for {shp_key}")
            return 0
        
        # Read shapefile with geopandas
        try:
            gdf = gpd.read_file(shp_file)
        except Exception as e:
            print(f"Error reading shapefile {shp_file}: {str(e)}")
            # Try with different encoding
            try:
                gdf = gpd.read_file(shp_file, encoding='utf-8')
            except Exception as e2:
                try:
                    gdf = gpd.read_file(shp_file, encoding='latin1')
                except Exception as e3:
                    print(f"Could not read shapefile with any encoding: {str(e3)}")
                    return 0
        
        if gdf.empty:
            print(f"Shapefile {shp_file} is empty")
            return 0
        
        # Convert to WGS84 if not already
        try:
            if gdf.crs and gdf.crs != 'EPSG:4326':
                gdf = gdf.to_crs('EPSG:4326')
        except Exception as e:
            print(f"Error converting CRS for {shp_file}: {str(e)}")
            # Continue with original CRS if conversion fails
        
        # Extract base name for output folder structure
        shp_basename = os.path.basename(shp_key)[:-4]  # Remove .shp
        
        # Process each feature
        for idx, row in gdf.iterrows():
            try:
                # Generate unique ID for the feature
                feature_id = str(uuid.uuid4())
                
                # Validate and fix geometry
                geom = row.geometry
                if geom is not None:
                    geom = validate_and_fix_geometry(geom)
                    
                    # Skip features with unfixable geometries
                    if geom is None:
                        print(f"Skipping feature {idx} due to invalid geometry")
                        continue
                    
                    # Round coordinates to 6 decimal places
                    geom = round_coordinates(geom, 6)
                
                # Create GeoJSON feature
                feature = {
                    "type": "Feature",
                    "id": feature_id,
                    "geometry": mapping(geom) if geom is not None else None,
                    "properties": {}
                }
                
                # Add all non-geometry columns as properties
                for col in gdf.columns:
                    if col != 'geometry':
                        value = row[col]
                        # Convert numpy types to Python types
                        if hasattr(value, 'item'):
                            value = value.item()
                        # Handle None/NaN values
                        if value is None or (isinstance(value, float) and value != value):
                            value = None
                        feature["properties"][col] = value
                
                # Add metadata
                feature["properties"]["_source_file"] = shp_key
                feature["properties"]["_shapefile_name"] = shp_basename
                feature["properties"]["_folder_name"] = folder_name
                feature["properties"]["_feature_index"] = idx
                feature["properties"]["_processed_timestamp"] = datetime.utcnow().isoformat()
                
                # Determine output path maintaining folder structure
                output_key = f"{target_folder}/{folder_name}/{shp_basename}/{feature_id}.geojson"
                
                # Convert to JSON with proper formatting
                try:
                    geojson_content = json.dumps(feature, separators=(',', ':'))
                except (TypeError, ValueError) as e:
                    print(f"Error serializing feature {idx} to JSON: {str(e)}")
                    continue
                
                # Upload to S3
                try:
                    s3_client.put_object(
                        Bucket=target_bucket,
                        Key=output_key,
                        Body=geojson_content,
                        ContentType='application/geo+json'
                    )
                except Exception as e:
                    print(f"Error uploading feature {idx} to S3: {str(e)}")
                    continue
                
                processed_count += 1
                
            except Exception as e:
                print(f"Error processing feature {idx} in {shp_key}: {str(e)}")
                continue
        
        print(f"Processed {processed_count} features from {shp_key}")
        
    except Exception as e:
        print(f"Error processing shapefile {shp_key}: {str(e)}")
    
    finally:
        # Clean up temporary directory
        shutil.rmtree(temp_dir)
    
    return processed_count

def main():
    """Main ETL process"""
    total_features = 0
    processed_files = 0
    
    try:
        # Get all folders
        folders = list_shapefile_folders()
        print(f"Found {len(folders)} folders to process: {folders}")
        
        for folder in folders:
            print(f"\nProcessing folder: {folder}")
            
            # Find all shapefiles in the folder
            shapefiles = find_shapefiles(folder)
            print(f"Found {len(shapefiles)} shapefiles in {folder}")
            
            for shp_key in shapefiles:
                try:
                    features = process_shapefile_to_geojson(shp_key, folder)
                    total_features += features
                    processed_files += 1
                except Exception as e:
                    print(f"Error processing {shp_key}: {str(e)}")
                    continue
        
        print(f"\nETL completed successfully!")
        print(f"Total shapefiles processed: {processed_files}")
        print(f"Total features converted: {total_features}")
        
    except Exception as e:
        print(f"ETL job failed: {str(e)}")
        raise e
    
    job.commit()

if __name__ == "__main__":
    main()