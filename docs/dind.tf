# Provider Docker
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

# Creamos la red Docker bridge para conectar Jenkins y dind
resource "docker_network" "jenkins_network" {
  name = "red_jenkins"
}

# Creamos el contenedor dind con la imagen docker:dind
resource "docker_container" "jenkins_docker" {
  name         = "jenkins-docker"
  image        = "docker:dind"
  network_mode = docker_network.jenkins_network.name
  ports {
    internal = 2376
    external = 2376
  }

  ports {
    internal = 3000
    external = 3000
  }

  ports {
    internal = 5000
    external = 5000
  }

  env = [
    "DOCKER_TLS_CERTDIR = /certs"
  ]

  restart = "no"

  privileged = "true"  

  volumes {
    volume_name    = "jenkins-docker-certs"
    container_path = "/certs/client"
  }

  volumes {
    volume_name    = "jenkins-data"
    container_path = "/var/jenkins_home"
  }

  volumes {
    volume_name    = "jenkins-socket"
    container_path = "/var/run/docker.sock"
  }

  networks_advanced {
    name    = docker_network.jenkins_network.name
    aliases = ["red_jenkins"]
  }
}

