import json
import boto3
import os
import uuid

s3 = boto3.client("s3")
bucket_name = os.environ["FILES_BUCKET"]

def handler(event, context):
    print("Event:", json.dumps(event))

    file_id = str(uuid.uuid4()) + ".txt"  # random file name, you can change logic

    url = s3.generate_presigned_url(
        "put_object",
        Params={"Bucket": bucket_name, "Key": file_id},
        ExpiresIn=3600  # URL valid for 1 hour
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"upload_url": url, "file_id": file_id})
    }
