variable "ec2_name" {
  description = "Nome da Instancia EC2"
  type        = string
}

variable "nome_chave" {
  type        = string
  description = "Nome da Chave SSh"
}

variable "contato" {
  type        = string
  description = "Info de contato"
  default     = "fabiomfrade@gmail.com"
}

variable "tamanho_ec2" {
  type        = string
  description = "Tipo da instancia EC2"
  default     = "t3a.micro"
}
