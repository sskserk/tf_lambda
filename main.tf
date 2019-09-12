provider "aws" {
  region = "${var.aws_region}"
}

data "aws_caller_identity" "current" {}

# First, we need a role to play with Lambda
resource "aws_iam_role" "iam_role_for_lambda" {
  name = "iam_role_for_lambda"


  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Here is a first lambda function that will run the code `hello_lambda.handler`
module "lambda_get" {
  source  = "./lambda"
  name    = "tour_lambda"
  handler = "com.srk.lambda.Handler"
  runtime = "java8"
  role    = "${aws_iam_role.iam_role_for_lambda.arn}"
}

# This is a second lambda function that will run the code
# `hello_lambda.post_handler`
//module "lambda_post" {
//  source  = "./lambda"
//  name    = "hello_lambda"
//  handler = "post_handler"
//  runtime = "python2.7"
//  role    = "${aws_iam_role.iam_role_for_lambda.arn}"
//}

# Now, we need an API to expose those functions publicly
resource "aws_api_gateway_rest_api" "tour_api" {
  name = "tour_api"
}

# The API requires at least one "endpoint", or "resource" in AWS terminology.
# The endpoint created here is: /hello
resource "aws_api_gateway_resource" "tour_api_res_hello" {
  rest_api_id = "${aws_api_gateway_rest_api.tour_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.tour_api.root_resource_id}"
  path_part   = "tour"
}

# Until now, the resource created could not respond to anything. We must set up
# a HTTP method (or verb) for that!
# This is the code for method GET /hello, that will talk to the first lambda
module "tour_module" {
  source      = "./api_method"
  rest_api_id = "${aws_api_gateway_rest_api.tour_api.id}"
  resource_id = "${aws_api_gateway_resource.tour_api_res_hello.id}"
  method      = "ANY"
  path        = "${aws_api_gateway_resource.tour_api_res_hello.path}"
  lambda      = "${module.lambda_get.name}"
  region      = "${var.aws_region}"
  account_id  = "${data.aws_caller_identity.current.account_id}"
}

# This is the code for method POST /hello, that will talk to the second lambda
//module "hello_post" {
//  source      = "./api_method"
//  rest_api_id = "${aws_api_gateway_rest_api.hello_api.id}"
//  resource_id = "${aws_api_gateway_resource.tour_api_res_hello.id}"
//  method      = "POST"
//  path        = "${aws_api_gateway_resource.tour_api_res_hello.path}"
//  lambda      = "${module.lambda_post.name}"
//  region      = "${var.aws_region}"
//  account_id  = "${data.aws_caller_identity.current.account_id}"
//}

# We can deploy the API now! (i.e. make it publicly available)
resource "aws_api_gateway_deployment" "tour_api_deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.tour_api.id}"
  stage_name  = "api"
  description = "Deploy methods: ${module.tour_module.http_method}"
}
