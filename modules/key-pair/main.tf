# Key pair
resource "tls_private_key" "WebServer_ed25519" {
    algorithm = "ED25519"
}

resource "aws_key_pair" "WebServer_ssh_keys" {
    key_name = var.key_name
    public_key = tls_private_key.WebServer_ed25519.public_key_openssh
}

# Save key on host
resource "local_file" "private_key" {
    content = tls_private_key.WebServer_ed25519.private_key_openssh
    filename = var.key_name
}
