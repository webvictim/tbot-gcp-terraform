terraform {
    required_providers {
        teleport = {
            source  = "terraform.releases.teleport.dev/gravitational/teleport"
            version = "14.3.3"
        }
    }
}

provider "teleport" {
    # Update addr to point to your Teleport proxy server
    addr               = var.teleport_proxy_address
    identity_file_path = "/tbot-output/identity"
}