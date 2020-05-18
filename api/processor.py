import time
import boto3
import base64
import uuid
import os


def lambda_handler(event, context):
    try:
        if event['operation'] == "upload":
            response = add_update_user_details(event)
        elif event['operation'] == "verify":
            response = image_verification(event)
        return response
    except Exception as e:
        print(e)
        raise e


def add_update_user_details(event):
    image_id = event['user_id'] + "_" + str(uuid.uuid4())
    dynamodb = boto3.resource('dynamodb',
                              endpoint_url='http://localhost:32768')  # todo: difference between boto3.resource and boto3.client
    timestamp = str(time.time())
    table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
    item = {
        'UserId': event['user_id'],
        'ImageId': image_id,
        'ImageData': event['image_data'],
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
    existing_images = get_images(event["user_id"])  # todo: condition if get_image is empty
    # print("EXISTING IMAGES OBJ", existing_images)
    if not existing_images:
        return "No images present for this user"
    else:
        responses = []
        for img in existing_images:
            response = client.compare_faces(
                SourceImage={
                    'Bytes': base64.b64decode(event["image_data"])
                },
                TargetImage={
                    'Bytes': base64.b64decode(img['ImageData']['S'])
                },
                SimilarityThreshold=90
            )["FaceMatches"]
            # print("breakpoint", response)
            if not response:
                message = "This Image is not part of your existing collection"
            else:
                message = "Face detected in image and its a " + str(
                    round(int(response[0]['Similarity']), 2)) + "% match"
            responses.append({
                "image_data": img['ImageData']['S'],
                "message": message
            })
        return responses


def get_images(user_id):
    table = os.environ['DYNAMODB_TABLE']
    client = boto3.client('dynamodb', endpoint_url='http://localhost:32768')
    response = client.query(
        TableName=table,
        IndexName='UserId-index',
        ProjectionExpression='ImageData',
        KeyConditionExpression='UserId = :v1',
        ExpressionAttributeValues={
            ':v1': {
                'S': user_id,
            }
        }
    )
    return response["Items"]
