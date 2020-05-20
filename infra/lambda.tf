data "archive_file" "processor_artifact" {
  type = "zip"
  source_file = "${path.module}/api/processor.py"
  output_path = "${path.module}/api/processor.zip"
}

resource "aws_lambda_function" "processor_lambda" {
  depends_on = [
    aws_iam_role.iam_for_lambda,
    data.archive_file.processor_artifact,
    aws_dynamodb_table.image_details]
  filename = "${path.module}/api/processor.zip"
  function_name = "processor"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "processor.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("processor.zip")

  runtime = "python3.7"

  environment {
    variables = {
      DYNAMODB_TABLE = "ImageDetails",
      PROCESSOR_ENV = "prod",
      DYNAMODB_TABLE_INDEX = "UserId-index"
    }
  }
}