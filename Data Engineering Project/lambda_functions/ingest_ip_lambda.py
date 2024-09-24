import json
import boto3
import urllib3
import datetime

# Set variable name for Data Ingestion S3 Bucket
S3_BUCKET = 'data-ingest-101-bucket'

def lambda_handler(event, context):
    http = urllib3.PoolManager()
    
    r = http.request("GET", "https://api.ipify.org?format=json")
    
    # Create dictionary from JSON
    r_dict = json.loads(r.data.decode(encoding='utf-8', errors='strict'))
    
    # Extract values from the dictionary
    processed_dict = {}
    processed_dict['ip_address'] = r_dict['ip']
    processed_dict['time_captured'] = str(datetime.datetime.now())
    
    # Convert to a string and add a newline
    msg = f"{processed_dict['ip_address']},{processed_dict['time_captured']}"
    

    s3_client = boto3.client('s3')
    
    reply = s3_client.put_object(Body=msg, Bucket=S3_BUCKET, Key=f"new_file_{int(datetime.datetime.now().timestamp())}.csv")
    
    return reply

