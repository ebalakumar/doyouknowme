import json
import urllib.parse
import time
import boto3
import base64
import uuid
import os


def lambda_handler(event, context):
    # raise Exception('Something went wrong')
    # print("Received event: " + json.dumps(event, indent=2))

    # Get the object from the event and show its content type
    # bucket = event['Records'][0]['s3']['bucket']['name']
    # key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        if event['operation'] == "upload":
            if verify_secret_key(event["secret_code"]):
                # response = upload_image(event)
                response = get_images(event["user_id"])
            else:
                return "invalid secret code"  # todo: return proper error type
        elif event['operation'] == "verify":
            image_verification(event)

        return response

        # response = s3.get_object(Bucket=bucket, Key=key)
        # print("CONTENT TYPE: " + response['ContentType'])
        # return response['ContentType']
        # print("Received event: " + json.dumps(event, indent=2))
        # print("value1 = " + event['key1'])
        # print("value2 = " + event['key2'])
        # print("value3 = " + event['key3'])
        # return event['key1']  # Echo back the first key value
    except Exception as e:
        print(e)
        # print(
        #     'Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as '
        #     'this function.'.format(
        #         key, bucket))
        raise e


def verify_secret_key(secret_key) -> bool:
    return True


def upload_image(event):
    s3 = boto3.client('s3')
    image_data = base64.b64decode(event['image_data'])
    image_id = event['user_id'] + "_" + str(uuid.uuid4())
    bucket_name = os.environ['S3_BUCKET']
    response = s3.put_object(
        # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html#S3.Client.put_object
        Body=image_data,
        Bucket=bucket_name,
        Key=image_id + '.jpeg',
        ContentType='image/jpeg'
    )
    if (response["ResponseMetadata"])["HTTPStatusCode"] == 200:
        print("Successfully uploaded image to S3")
        return add_update_user_details(image_id, event)
    else:
        return Exception("Image upload to S3 failed")


def add_update_user_details(image_id, event):
    dynamodb = boto3.resource('dynamodb',
                              endpoint_url='http://localhost:32769')  # todo: difference between boto3.resource and boto3.client
    timestamp = str(time.time())
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
    item = {
        'UserId': event['user_id'],
        'ImageId': image_id,
        'CreatedAt': timestamp,  # todo: set UTC timestamp
        'UpdatedAt': timestamp,
    }

    # write the todo to the database
    response = table.put_item(Item=item)
    if (response["ResponseMetadata"])["HTTPStatusCode"] == 200:
        print("Successfully updated details to DynamoDB")
        return event['operation'] + " operation completed"
    else:
        return Exception("Details update to DynamoDB failed")


def image_verification(event):
    client = boto3.client('rekognition')
    bucket_name = os.environ['S3_BUCKET']
    response = client.compare_faces(
        SourceImage={
            'Bytes': b'bytes',
            'S3Object': {
                'Bucket': 'string',
                'Name': 'string',
                'Version': 'string'
            }
        },
        TargetImage={
            'Bytes': b'bytes',
            'S3Object': {
                'Bucket': 'string',
                'Name': 'string',
                'Version': 'string'
            }
        },
        SimilarityThreshold=...,
        QualityFilter='NONE' | 'AUTO' | 'LOW' | 'MEDIUM' | 'HIGH'
    )


def get_images(user_id):
    # client = boto3.client('dynamodb')
    table = os.environ['DYNAMODB_TABLE']
    client = boto3.client('dynamodb', endpoint_url='http://localhost:32769')
    response = client.get_item(
        Key={
            'UserId': {
                'S': user_id
            }
        },
        TableName=table
    )
    return response
