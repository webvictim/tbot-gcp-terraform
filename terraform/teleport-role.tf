resource "teleport_role" "terraform-test" {
  metadata = {
    name        = "terraform-test"
    description = "Terraform test role"
    labels = {
      example  = "true"
      purpose = "terraform"
    }
  }

  spec = {
    options = {
      forward_agent           = false
      max_session_ttl         = "30m"
      port_forwarding         = false
      client_idle_timeout     = "1h"
      disconnect_expired_cert = true
      permit_x11_forwarding    = false
      request_access          = "denied"
    }

    allow = {
      logins = ["dummy-user"]

      windows_desktop_logins = ["dummy-windows-user"]

      rules = [{
        resources = ["user", "role"]
        verbs = ["list"]
      }]

      request = {
        roles = ["example-role"]
        claims_to_roles = [{
          claim = "example-claim"
          value = "example-value"
          roles = ["example-role"]
        }]
      }

      node_labels = {
         key = ["example-node-label"]
         value = ["yes"]
      }
    }

    deny = {
      logins = ["anonymous-user"]
    }
  }
}