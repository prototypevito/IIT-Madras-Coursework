import os
from concurrent.futures import TimeoutError
from google.cloud import pubsub_v1
from google.cloud import storage
import base64

project_id = "lab6-project-380911"
topic_id = "pubsub-lab6-be19b002"
subscription_id = "linecount-sub-final3"

# Create a subscriber client
subscriber = pubsub_v1.SubscriberClient()
subscription_path = subscriber.subscription_path(project_id, subscription_id)

def callback(message):
    # Decode the filename back to string
    filename = message.data.decode("utf-8")
    print("Received file: {}".format(filename))
    
    # Create a google storage client to read the uploaded file from bucket.
    storage_client = storage.Client()
    bucket = storage_client.get_bucket("devansh_be19b002_pubsub")
    
    blob = bucket.blob(filename)
    blob = blob.download_as_string()
    blob = blob.decode('utf-8') # Decodes bytes to string
    lines = blob.splitlines() # Splits the text based on \n. 
    print("Number of lines in {}: {}".format(filename, len(lines))) # Number of lines = Number of \n
    
    message.ack() # Acknowledge that the message is recieved.

# Default subscriber is a pull subscriber
pull_sub_future = subscriber.subscribe(subscription_path, callback=callback)
print("Listening for the messages on {}..\n".format(subscription_path))

# By using 'with', the subscriber closes automatically.
with subscriber:
    try:
        # The subscriber listens indefinitely 
       ret = pull_sub_future.result()
    except TimeoutError:
        pull_sub_future.cancel()