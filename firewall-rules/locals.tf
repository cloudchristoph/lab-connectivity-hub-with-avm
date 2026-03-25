locals {

  ip_groups = {

    oad_azurefirewall = {
      name = "ipgroup-oad-azurefirewall"
      ip_addresses = [
        "10.3.1.0/24",
        "10.3.2.0/24",
        "10.3.3.0/24",
        "10.3.4.0/24",
        "10.3.5.0/24"
      ]
    }

    on_premises = {
      name = "ipgroup-onpremises"
      ip_addresses = [
        "10.1.0.0/16"
      ]
    }

    cclab = {
      name = "ipgroup-cclab"
      ip_addresses = [
        "10.2.0.0/16",
        "10.3.0.0/16"
      ]
    }

    webapp_demo = {
      name = "ipgroup-webapp-demo"
      ip_addresses = [
        "10.2.10.0/24"
      ]
    }
  }
}
