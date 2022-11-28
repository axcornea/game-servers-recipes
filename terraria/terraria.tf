variable "gcp_credentials" {
  type = string
}

variable "gcp_project" {
  type = string
}

variable "gcp_zone" {
  type = string
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file(var.gcp_credentials)
  project     = var.gcp_project
  zone        = var.gcp_zone
}

resource "random_string" "resource_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "google_compute_instance" "terraria_server" {
  name         = "terraria-server-${random_string.resource_suffix.result}"
  machine_type = "n2-standard-4"

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-lts"
    }
  }

  metadata_startup_script = templatefile("templates/setup_terraria_server.sh.tftpl", {})

  network_interface {
    network = "default"

    access_config {
    }
  }

  service_account {
    scopes = []
  }
}

resource "google_compute_instance" "terraria_proxy" {
  name         = "terraria-proxy-${random_string.resource_suffix.result}"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-lts"
    }
  }

  metadata_startup_script = templatefile("templates/setup_terraria_proxy.sh.tftpl", {
    GCP_ZONE             = var.gcp_zone,
    TERRARIA_SERVER_NAME = google_compute_instance.terraria_server.name,
  })

  network_interface {
    network = "default"

    access_config {
    }
  }

  tags = ["terraria-server"]

  service_account {
    scopes = [
      "compute-rw"
    ]
  }
}

resource "google_compute_firewall" "terraria_firewall_rule" {
  name    = "allow-terraria-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["7777"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["terraria-server"]
}

output "terraria_proxy_ip" {
  value = google_compute_instance.terraria_proxy.network_interface.0.access_config.0.nat_ip
}
