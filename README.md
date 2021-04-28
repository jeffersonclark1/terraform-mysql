# TERRAFORM MYSQL
## _Infrastructure and Cloud Computing - MBA ES21_

## Desafio

> Subir uma máquina virtual no Azure, AWS ou GCP instalando o MySQL e que esteja acessível no host da máquina na porta 3306, usando Terraform. Se quiser usar o Ansible para configurar a máquina é interessante mas não obrigatório, pode configurar via script também. Enviar a URL GitHub do código.

## Tech

Tecnologias utilizadas

- [MySQL](https://www.mysql.com/) - O MySQL é um sistema de gerenciamento de banco de dados, que utiliza a linguagem SQL como interface
- [Terraform](https://www.terraform.io/) - Terraform é uma infraestrutura de código aberto como ferramenta de software de código criada pela HashiCorp
- [Azure](https://azure.microsoft.com/) - Azure é uma plataforma destinada à execução de aplicativos e serviços, baseada nos conceitos da computação em nuvem

## Instalação


```sh
mkdir terraform && cd terraform
git clone https://github.com/jeffersonclark1/terraform-mysql.git
terraform init
terraform plan
terraform apply
```

> Observação : liberar o IP no firewall do azure para conseguir conectar na MySQL

## Credenciais MySQL

- User : mysqladminun 
- Password : H@Sh1CoR3!


```sh
mysql -u root -p
CREATE DATABASE dbname;
USE dbname;
CREATE TABLE example ( id smallint unsigned not null auto_increment, name varchar(20) not null, constraint pk_example primary key (id) );
INSERT INTO example ( id, name ) VALUES ( null, 'Sample data' );
SELECT * FROM example;
```

## License

MIT

**Let's GO**