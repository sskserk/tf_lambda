
resource "aws_api_gateway_method" "request_method" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${var.resource_id}"
  http_method   = "${var.method}"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "request_method_integration" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method.request_method.http_method}"
  type        = "AWS_PROXY"
  uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.lambda}/invocations"

  integration_http_method = "POST"
}

# lambda => GET response
resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_integration.request_method_integration.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method_response.response_method.http_method}"
  status_code = "${aws_api_gateway_method_response.response_method.status_code}"

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  function_name = "${var.lambda}"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${var.rest_api_id}/*/*/*"
}

####################################################################
# root resource "/"

resource "aws_api_gateway_method" "root_method" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${var.root_resource_id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_integration" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.root_resource_id}"
  http_method = "${aws_api_gateway_method.root_method.http_method}"

  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.lambda}/invocations"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "s200" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.root_resource_id}"
  http_method = "${aws_api_gateway_method.root_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "root_integration_response" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.root_resource_id}"
  http_method = "${aws_api_gateway_method_response.s200.http_method}"
  status_code = "${aws_api_gateway_method_response.s200.status_code}"
  depends_on  = ["aws_api_gateway_integration.root_integration"]
}