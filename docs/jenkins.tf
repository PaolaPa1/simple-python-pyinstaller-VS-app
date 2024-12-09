resource "docker_image" "myjenkins_bo" {
  name = "myjenkins_bo:latest"
}

# Contenedor Jenkins con la imagen personalizada con Dockerfile
resource "docker_container" "jenkins_blueocean" {
  name  = "jenkins-blueocean"
  image = docker_image.myjenkins_bo.name
  #detach = true
  # Se reinicia automáticamente en caso de error
  #restart = on-failure

  # Se conecta a la red
  network_mode = docker_network.jenkins_network.name

  # Variables de entorno
  env = [
    "DOCKER_HOST = tcp://jenkins-docker:2376",
    "DOCKER_CERT_PATH = /certs/client",
    "DOCKER_TLS_VERIFY = 1"
  ]

  privileged = "true"

  networks_advanced {
    name    = docker_network.jenkins_network.name
    aliases = ["red_jenkins"]
  }

  # Volúmenes
  volumes {
    volume_name = "jenkins-data"
    container_path = "/var/jenkins_home"
  }

  volumes {
    volume_name = "jenkins-docker-certs"
    container_path= "/certs/client"
    read_only = true
  }
  
  ports {
    internal = 8080
    external = 8080
  }

  ports {
    internal = 50000
    external = 50000
  }
}
