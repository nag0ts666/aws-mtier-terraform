import json
import boto3
import os

s3 = boto3.client("s3")
bucket_name = os.environ["FILES_BUCKET"]

def handler(event, context):
    try:
        # For testing, we’ll expect ?file_id=<filename> in the query string
        file_id = event.get("queryStringParameters", {}).get("file_id", None)
        if not file_id:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing file_id parameter"})
            }

        url = s3.generate_presigned_url(
            "get_object",
            Params={"Bucket": bucket_name, "Key": file_id},
            ExpiresIn=3600  # 1 hour validity
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"download_url": url})
        }

    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
