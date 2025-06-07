# Infraestructura GitOps con Terraform/OpenTofu, Kind, Crossplane y Argo CD

Este proyecto despliega una infraestructura en AWS utilizando Terraform/OpenTofu. Incluye la creación de una red VPC, una instancia EC2 y la configuración automatizada de un clúster Kubernetes local con Kind, listo para gestionar infraestructura como código con Crossplane y aplicaciones con Argo CD.

## Componentes principales

- **Terraform / OpenTofu**: para orquestar toda la infraestructura de AWS (VPC, Subnets, Security Groups, EC2).
- **Docker**: como base para ejecutar Kind.
- **Kind**: clúster Kubernetes dentro de la instancia EC2.
- **Helm**: gestor de paquetes de Kubernetes.
- **Crossplane**: para gestionar recursos de nube desde Kubernetes.
- **Argo CD**: controlador GitOps para despliegue de manifiestos desde GitHub.

## ¿Qué hace este proyecto?

1. Provisiona:
   - VPC, Subnet, Internet Gateway y Security Group.
   - Instancia EC2 (Amazon Linux 2023).
2. Configura automáticamente en la EC2:
   - Docker y Kind.
   - Clúster Kubernetes local.
   - Instalación de kubectl y helm.
   - Despliegue de Argo CD y Crossplane.
3. Expone Argo CD vía port-forwarding con systemd.
4. Permite verificar el estado con un script de diagnóstico.
5. Todo ejecutado sin intervención manual mediante `user_data`.

## Estructura del repositorio

- red.tf
- seguridad.tf
- ec2.tf
- variables.tf
- outputs.tf
- user_data.sh
- README.md

## Cómo usar

1. Clona el repo:
```bash
git clone https://github.com/alejandroroig/infra-crossplane-argocd.git
cd infra-crossplane-argocd
```

2. Inicializa y aplica Tofu:
```bash
tofu init
tofu apply
```

3. Accede a la IP pública de la EC2 una vez creada, y verifica:
```bash
ssh -i <tu-clave.pem> ec2-user@<ip-publica>
./verificar_instalacion.sh
```

4. Accede a Argo CD desde el navegador:
```bash
https://<ip-publica>:8443 ó http://<ip-publica>:8080
Usuario: admin    
Contraseña: nombre del pod argocd-server (obtenido con kubectl).
```    

Ya puedes crea una aplicación en Argo CD apuntando a un repositorio o aplicar tus propios manifiestos con Crossplane.