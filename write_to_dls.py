import os
import time
from azure.storage.blob import BlobServiceClient

# Configuration
STORAGE_ACCOUNT_NAME = "your_storage_account_name"
CONTAINER_NAME = "your_container_name"
STORAGE_ACCESS_KEY = "your_storage_access_key"
LOCAL_FILE_PATH = "C:/path/to/your/local/file.txt"  # Replace with your actual file path
BLOB_PREFIX = "folder_in_datalake/file_"  # Prefix for each file in the container
NUM_COPIES = 10000  # Total number of copies
BATCH_SIZE = 1000  # Log start/end time every 1000 copies

# Construct the Blob Service Client using the access key
connection_string = f"DefaultEndpointsProtocol=https;AccountName={STORAGE_ACCOUNT_NAME};AccountKey={STORAGE_ACCESS_KEY};EndpointSuffix=core.windows.net"
blob_service_client = BlobServiceClient.from_connection_string(connection_string)
container_client = blob_service_client.get_container_client(CONTAINER_NAME)

def upload_files():
    try:
        start_time = time.time()  # Track overall start time

        for i in range(1, NUM_COPIES + 1):
            blob_name = f"{BLOB_PREFIX}{i}.txt"  # Append number to file name
            blob_client = container_client.get_blob_client(blob_name)

            with open(LOCAL_FILE_PATH, "rb") as data:
                blob_client.upload_blob(data, overwrite=True)

            # Log the start and end time every 1000 copies
            if i % BATCH_SIZE == 1:
                batch_start_time = time.time()
                print(f"Started batch {i} at {time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(batch_start_time))}")

            if i % BATCH_SIZE == 0:
                batch_end_time = time.time()
                print(f"Completed {i} copies at {time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(batch_end_time))}. Time taken: {batch_end_time - batch_start_time:.2f} seconds")

        end_time = time.time()  # Track overall end time
        print(f"\nAll {NUM_COPIES} files uploaded successfully!")
        print(f"Total time taken: {end_time - start_time:.2f} seconds")

    except Exception as e:
        print(f"Error: {e}")

# Run the function
upload_files()
