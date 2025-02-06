from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
import os

# Configuration
STORAGE_ACCOUNT_NAME = "your_storage_account_name"
CONTAINER_NAME = "your_container_name"
STORAGE_ACCESS_KEY = "your_storage_access_key"  # Get this from Azure portal
LOCAL_FILE_PATH = "C:/path/to/your/local/file.txt"  # Replace with your file path
BLOB_NAME = "folder_in_datalake/file.txt"  # Path inside the container

# Construct the Blob Service Client using the access key
connection_string = f"DefaultEndpointsProtocol=https;AccountName={STORAGE_ACCOUNT_NAME};AccountKey={STORAGE_ACCESS_KEY};EndpointSuffix=core.windows.net"
blob_service_client = BlobServiceClient.from_connection_string(connection_string)

def upload_file():
    try:
        # Get a client for the container
        container_client = blob_service_client.get_container_client(CONTAINER_NAME)

        # Get a client for the blob
        blob_client = container_client.get_blob_client(BLOB_NAME)

        # Read the local file and upload it
        with open(LOCAL_FILE_PATH, "rb") as data:
            blob_client.upload_blob(data, overwrite=True)

        print(f"File {LOCAL_FILE_PATH} uploaded successfully to {BLOB_NAME}")

    except Exception as e:
        print(f"Error: {e}")

# Run the function
upload_file()
