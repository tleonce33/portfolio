import sys
import json
import boto3

# Set Variable Names for S3 bucket, database, and table
BUCKET_TO_DEL = 'open-meteo-weather-data-parquet-bucket-1'
DATABASE_TO_DEL = 'de_proj_database'
TABLE_TO_DEL = 'open_meteo_weather_data_parquet_tbl'
QUERY_OUTPUT_BUCKET = 's3://query-results-location-de-proj-1/'


# Clear all objects in the S3 bucket
s3_client = boto3.client('s3')

while True:
    objects = s3_client.list_objects(Bucket=BUCKET_TO_DEL)
    content = objects.get('Contents', [])
    if len(content) == 0:
        break
    for obj in content:
        s3_client.delete_object(Bucket=BUCKET_TO_DEL, Key=obj['Key'])


# Drop the database table
client = boto3.client('athena')

queryStart = client.start_query_execution(
    QueryString = f"""
    DROP TABLE IF EXISTS {DATABASE_TO_DEL}.{TABLE_TO_DEL};
    """,
    QueryExecutionContext = {
        'Database': f'{DATABASE_TO_DEL}'
    }, 
    ResultConfiguration = { 'OutputLocation': f'{QUERY_OUTPUT_BUCKET}'}
)

# List of responses
resp = ["FAILED", "SUCCEEDED", "CANCELLED"]

# Get the response
response = client.get_query_execution(QueryExecutionId=queryStart["QueryExecutionId"])

# Wait until query finishes
while response["QueryExecution"]["Status"]["State"] not in resp:
    response = client.get_query_execution(QueryExecutionId=queryStart["QueryExecutionId"])
    
# If it fails, exit and give the Athena error message in the logs
if response["QueryExecution"]["Status"]["State"] == 'FAILED':
    sys.exit(response["QueryExecution"]["Status"]["StateChangeReason"])
