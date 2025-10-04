import json

def handler(event, context):
    print("Event:", json.dumps(event))

    response = {
        "statusCode": 200,
        "body": json.dumps({"message": "Hello from pranav-list-files Lambda (Python)!"})
    }

    return response
