# Packer образ
source "yandex" "ubuntu-nginx" {
  token               = "<OAuth-токен>"
  folder_id           = "<идентификатор_каталога>"
  source_image_id     = "!!! ИДЕНТИФИКАТОР ОБРАЗА ubuntu-2004-lts" 
  ssh_username        = "ubuntu"
  use_ipv4_nat        = "true"
  image_description   = "my custom ubuntu with nginx"
  image_family        = "ubuntu-2004-lts"
  image_name          = "my-ubuntu-nginx"
  subnet_id           = "<идентификатор подсети>"
  disk_type           = "network-hdd"
  zone                = "ru-central1-a"
}
 
build {
  sources = ["source.yandex.ubuntu-nginx"]
 
  provisioner "shell" {
    inline = ["sudo apt-get update -y", 
              "sudo apt-get install -y nginx", 
              "sudo systemctl enable nginx.service"
             ]
  }
}
