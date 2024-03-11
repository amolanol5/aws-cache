output "instance_db_host" {
  value = aws_db_instance.this.address
}

output "url_lambda" {
  value = aws_lambda_function_url.url_latest.function_url
}