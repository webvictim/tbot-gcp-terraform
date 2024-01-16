resource "teleport_user" "terraform-test" {
  metadata = {
    name        = "terraform-test"
    description = "Test terraform user"

    labels = {
      test      = "true"
    }
  }

  spec = {
    roles = ["terraform-test"]
  }
}