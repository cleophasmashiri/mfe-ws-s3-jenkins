import json
import boto3
import mimetypes
import base64

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    print('event')
    print(event)
    if 'path' in event:
        request_path = event['path']
        key = request_path.lstrip('/')
    else:
        # If 'path' key does not exist, set a default value or handle it gracefully
        request_path = "Path not found"
        key = 'index.html';
    bucket_name = 'dashboard-2019'
    
    # key = 'images/satellite.png'
    # Fetch the object from S3
    try:
        # Determine the file's content type (e.g., image/png, text/css, etc.)
        content_type, _ = mimetypes.guess_type(key)
        if not content_type:
            content_type = "application/octet-stream"  # Default content type if unknown
        # Check if the file should be base64-encoded (e.g., for images)
        is_binary = content_type.startswith("image/") or content_type.startswith("application/octet-stream")
        s3_response = s3_client.get_object(Bucket=bucket_name, Key=key)
        if is_binary:
            # If binary, return base64-encoded content
            file_content = s3_response['Body'].read()
            body = base64.b64encode(file_content).decode('utf-8')
        
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': content_type
                },
                'body': body,
                'isBase64Encoded': True
            }
        else:
            return {
                'statusCode': 200,
                'headers': {'Content-Type': content_type},
                'body': s3_response['Body'].read().decode('utf-8')
            }
    except Exception as e:
        print(e);
        return {
            'statusCode': 404,
            'body': json.dumps(f'Error: {str(e)}')
        }
 