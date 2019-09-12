resource "aws_lambda_function" "lambda" {
  filename      = "jv/target/jv-1.0.jar"
  function_name = "${var.name}_tour"
  role          = "${var.role}"
  #handler       = "${var.name}.${var.handler}"
  handler = "com.srk.lambda.Handler"
  runtime = "${var.runtime}"
  memory_size="512"
}
