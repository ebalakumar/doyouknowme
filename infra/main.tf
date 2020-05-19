resource "aws_iam_policy" "processor_access_ImageDetails" {
  name = "processor_access_ImageDetails"
  path = "/"
  description = "Allowing Processor to access ImageDetails table"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:PutItem",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem"
            ],
            "Resource": [
                "arn:aws:dynamodb:ap-south-1:818087033500:table/ImageDetails",
                "arn:aws:dynamodb:ap-south-1:818087033500:table/ImageDetails/index/UserId-index"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:ListContributorInsights",
                "dynamodb:DescribeReservedCapacityOfferings",
                "dynamodb:ListGlobalTables",
                "dynamodb:ListTables",
                "dynamodb:DescribeReservedCapacity",
                "dynamodb:ListBackups",
                "dynamodb:DescribeLimits",
                "dynamodb:ListStreams"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "processor_use_aws_rekon" {
  name = "processor_use_aws_rekon"
  path = "/"
  description = "Allowing Processor to use AWS Rekognition"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "rekognition:CompareFaces",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "processor_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "processor_imagedetails_role_attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.processor_access_ImageDetails.arn
}

resource "aws_iam_role_policy_attachment" "processor_aws_rekon_role_attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.processor_use_aws_rekon.arn
}

//resource "aws_lambda_function" "processor_lambda" {
//  filename = "processor.zip"
//  function_name = "lambda_function_name"
//  role = aws_iam_role.iam_for_lambda.arn
//  handler = "exports.test"
//
//  # The filebase64sha256() function is available in Terraform 0.11.12 and later
//  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
//  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
//  source_code_hash = filebase64sha256("processor.zip")
//
//  runtime = "python3.7"
//
//  environment {
//    variables = {
//      foo = "bar"
//    }
//  }
//}