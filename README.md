
base64 pic/pokemon.jpeg | pbcopy

aws s3api create-bucket --bucket my-bucket --region us-east-1


pyl -f lambda_handler -e env.json lambda_upload_s3.py inputs/user_1_img_1.json

aws dynamodb create-table \
    --table-name ImageDetails \
    --attribute-definitions AttributeName=UserId,AttributeType=S AttributeName=ImageName,AttributeType=S \
    --key-schema AttributeName=UserId,KeyType=HASH AttributeName=ImageName,KeyType=RANGE \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --endpoint-url http://localhost:32769
    
 docker run -d -P amazon/dynamodb-local

aws dynamodb describe-table \
    --table-name MusicCollection
    
aws dynamodb get-item \
    --table-name ImageDetails \
    --key dynamodb_input.json --endpoint-url http://localhost:32769
    
aws dynamodb batch-get-item --request-items file://request_dynamodb.json --endpoint-url http://localhost:32769

aws dynamodb scan --table-name ImageDetails --endpoint-url http://localhost:32768



---
aws dynamodb create-table \
    --table-name ImageDetails \
    --attribute-definitions AttributeName=ImageId,AttributeType=S AttributeName=UserId,AttributeType=S \
    --key-schema AttributeName=ImageId,KeyType=HASH AttributeName=UserId,KeyType=RANGE  \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --endpoint-url http://localhost:32768 \
    --global-secondary-indexes file://gsi.json

 aws dynamodb delete-table --table-name ImageDetails --endpoint-url http://localhost:32769

-----

aws dynamodb query \
    --table-name ImageDetails \
    --index-name UserId-index \
    --projection-expression "ImageId" \
    --key-condition-expression "UserId = :v1" \
    --expression-attribute-values file://expression-attributes.json \
    --endpoint-url http://localhost:32768