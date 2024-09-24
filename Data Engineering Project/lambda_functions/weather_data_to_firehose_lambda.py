import json
import boto3
import urllib3
import datetime

# REPLACE WITH YOUR DATA FIREHOSE NAME
FIREHOSE_NAME = 'PUT-S3-VAhha'

def lambda_handler(event, context):
    
    http = urllib3.PoolManager()
    
    r = http.request("GET", "https://api.open-meteo.com/v1/forecast?latitude=40.7826&longitude=-73.9656&current=temperature_2m&temperature_unit=fahrenheit&timezone=America%2FNew_York")
    
    # Create dictionary from JSON
    r_dict = json.loads(r.data.decode(encoding='utf-8', errors='strict'))
    
    # Extract values from the dictionary
    processed_dict = {}
    processed_dict['latitude'] = r_dict['latitude']
    processed_dict['longitude'] = r_dict['longitude']
    processed_dict['time'] = r_dict['current']['time']
    processed_dict['temp'] = r_dict['current']['temperature_2m']
    processed_dict['row_ts'] = str(datetime.datetime.now())
    
    # Convert to a string and add a newline
    msg = str(processed_dict) + '\n'
    
    fh = boto3.client('firehose')
    
    reply = fh.put_record(
        DeliveryStreamName=FIREHOSE_NAME,
        Record = {
                'Data': msg
                }
    )

    return reply
