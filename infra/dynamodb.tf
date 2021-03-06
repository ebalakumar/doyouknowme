resource "aws_dynamodb_table" "image_details" {
  name = "ImageDetails"
  billing_mode = "PROVISIONED"
  read_capacity = 5
  write_capacity = 5
  hash_key = "ImageId"
  range_key = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "ImageId"
    type = "S"
  }

  global_secondary_index {
    name = "UserId-index"
    hash_key = "UserId"
    //    range_key          = "TopScore"
    write_capacity = 5
    read_capacity = 5
    projection_type = "INCLUDE"
    non_key_attributes = [
      "ImageData"]
  }

  //  tags = {
  //    Name        = "dynamodb-table-1"
  //    Environment = "production"
  //  }
}