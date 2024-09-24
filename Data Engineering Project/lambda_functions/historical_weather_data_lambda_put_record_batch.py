import json
import boto3
import urllib3
import datetime

# REPLACE WITH YOUR DATA FIREHOSE NAME
FIREHOSE_NAME = 'PUT-S3-7NoT1'

def lambda_handler(event, context):
    
    http = urllib3.PoolManager()
    
    r = http.request("GET", "https://api.open-meteo.com/v1/forecast?latitude=40.7143&longitude=-74.006&daily=temperature_2m_max&temperature_unit=fahrenheit&timezone=America%2FNew_York&start_date=2024-04-01&end_date=2024-05-20")
    
    # Create dictionary from JSON
    r_dict = json.loads(r.data.decode(encoding='utf-8', errors='strict'))
    
    time_list = []
    for val in r_dict['daily']['time']:
        time_list.append(val)
    
    temp_list = []
    for temp in r_dict['daily']['temperature_2m_max']:
        temp_list.append(temp)
    
    # Extract values from the dictionary
    processed_dict = {}
    
    # Append to string running_msg
    running_msg = ''
    for i in range(len(time_list)):
        # Construct each record
        processed_dict['latitude'] = r_dict['latitude']
        processed_dict['longitude'] = r_dict['longitude']
        processed_dict['time'] = time_list[i]
        processed_dict['temp_f'] = temp_list[i]
        processed_dict['row_ts'] = str(datetime.datetime.now())
    
        # Add a newline to denote the end of a record
        # Add each record to the running_msg
        running_msg += str(processed_dict) + '\n'
        
    # Cast to string
    running_msg = str(running_msg)
    fh = boto3.client('firehose')
    
    reply = fh.put_record_batch(
        DeliveryStreamName=FIREHOSE_NAME,
        Records = [
                {'Data': running_msg}
                ]
    )

    return reply
