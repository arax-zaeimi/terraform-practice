provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# ----------------------------------------------------------------------------------------
# some S3 buckets.
# ----------------------------------------------------------------------------------------
resource "aws_s3_bucket" "mys3bucket" {
  bucket_prefix = var.main_bucket

}

# ----------------------------------------------------------------------------------------
# SQS queue
# ----------------------------------------------------------------------------------------
resource "aws_sqs_queue" "q" {
  name   = "s3-event-queue"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:s3-event-queue",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.mys3bucket.arn}" }
      }
    }
  ]
}
POLICY
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.mys3bucket.id

  queue {
    queue_arn = aws_sqs_queue.q.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
