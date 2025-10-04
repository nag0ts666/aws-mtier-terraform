import json
import boto3
import os

s3 = boto3.client("s3")
bucket_name = os.environ["FILES_BUCKET"]

def handler(event, context):
    try:
        file_id = event.get("queryStringParameters", {}).get("file_id", None)
        if not file_id:
            return {"statusCode": 400, "body": json.dumps({"error": "Missing file_id parameter"})}

        s3.delete_object(Bucket=bucket_name, Key=file_id)

        return {
            "statusCode": 200,
            "body": json.dumps({"message": f"File '{file_id}' deleted successfully!"})
        }

    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
