output "key_pair_name" {
  description = "Name of the AWS Key Pair"
  value = aws_key_pair.main.key_name
}

output "key_pair_id" {
  description = "ID of the AWS Key Pair"
  value = aws_key_pair.main.id
}

output "private_key_pem" {
  description = "Private key in PEM format"
  value = tls_private_key.main.private_key_pem
  sensitive = true
}

output "public_key_openssh" {
  description = "Public key in OpenSSH format"
  value = tls_private_key.main.public_key_openssh
}
