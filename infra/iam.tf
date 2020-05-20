resource "aws_iam_policy" "processor_access_imagedetails" {
  name = "processor_access_ImageDetails"
  path = "/"
  description = "Allowing Processor to access ImageDetails table"

  //  todo: Index name should not be hardcoded
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
                ${aws_dynamodb_table.image_details.arn},
                "${aws_dynamodb_table.image_details.arn}/index/UserId-index"
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
  policy_arn = aws_iam_policy.processor_access_imagedetails.arn
}

resource "aws_iam_role_policy_attachment" "processor_aws_rekon_role_attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.processor_use_aws_rekon.arn
}