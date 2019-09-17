provider "aws" {
  region = "${var.aws_region}"
}

data "aws_caller_identity" "current" {}

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

module "lambda_get" {
  source  = "./lambda"
  name    = "tour_lambda"
  handler = "com.srk.lambda.Handler"
  runtime = "java8"
  role    = "${aws_iam_role.iam_role_for_lambda.arn}"
}

resource "aws_api_gateway_rest_api" "tour_api" {
  name = "tour_api"
}

resource "aws_api_gateway_resource" "tour_api_res_hello" {
  rest_api_id = "${aws_api_gateway_rest_api.tour_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.tour_api.root_resource_id}"
  path_part   = "{proxy+}"
}

module "tour_module" {
  source           = "./api_method"
  rest_api_id      = "${aws_api_gateway_rest_api.tour_api.id}"
  resource_id      = "${aws_api_gateway_resource.tour_api_res_hello.id}"
  root_resource_id = "${aws_api_gateway_rest_api.tour_api.root_resource_id}"
  method           = "ANY"
  path             = "${aws_api_gateway_resource.tour_api_res_hello.path}"
  lambda           = "${module.lambda_get.name}"
  region           = "${var.aws_region}"
  account_id       = "${data.aws_caller_identity.current.account_id}"
}

resource "aws_api_gateway_deployment" "tour_api_deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.tour_api.id}"
  stage_name  = "api"
  description = "Deploy methods: ${module.tour_module.http_method}"
}
