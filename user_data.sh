#!/bin/bash
dnf update -y
dnf install -y git curl jq tar gzip

# Instalar y habilitar Docker
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user
newgrp docker

# Instalar kind
curl -L -o /usr/local/bin/kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x /usr/local/bin/kind

# Instalar kubectl
curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

# Instalar helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Crear clúster kind
export HOME=/home/ec2-user
kind create cluster --name argocd-crossplane

# Configurar kubectl para ec2-user
mkdir -p /home/ec2-user/.kube
cp -i /root/.kube/config /home/ec2-user/.kube/config
chown -R ec2-user:ec2-user /home/ec2-user/.kube

# Instalar Argo CD y Crossplane como ec2-user
sudo -u ec2-user helm repo add argo https://argoproj.github.io/argo-helm
sudo -u ec2-user helm repo add crossplane-stable https://charts.crossplane.io/stable
sudo -u ec2-user helm repo update

sudo -u ec2-user helm install argocd argo/argo-cd --namespace argocd --create-namespace
sudo -u ec2-user helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace  

# Crear servicio systemd para port-forward (8080 y 8443)
cat << 'EOF' > /etc/systemd/system/argocd-portforward.service
[Unit]
Description=Port forward Argo CD on ports 8080 (HTTP) and 8443 (HTTPS)
After=network.target

[Service]
User=ec2-user
ExecStart=/bin/bash -c '/usr/local/bin/kubectl port-forward svc/argocd-server -n argocd 8080:80 --address=0.0.0.0 & /usr/local/bin/kubectl port-forward svc/argocd-server -n argocd 8443:443 --address=0.0.0.0'
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable argocd-portforward.service
systemctl start argocd-portforward.service

# Crear script de verificación
cat << 'EOF' > /home/ec2-user/verificar_instalacion.sh
#!/bin/bash

echo "🔍 Verificando Docker..."
docker ps >/dev/null 2>&1 && echo "✅ Docker funciona correctamente" || echo "❌ Docker no está funcionando o no tienes permisos"

echo "🔍 Verificando clúster kind..."
kind get clusters && echo "✅ Clúster kind detectado" || echo "❌ No se detecta clúster kind"

echo "🔍 Verificando contexto de kubectl..."
kubectl config current-context && echo "✅ Contexto de kubectl configurado" || echo "❌ kubectl no tiene contexto configurado"

echo "🔍 Verificando nodos del clúster..."
kubectl get nodes && echo "✅ Clúster responde correctamente" || echo "❌ No se puede acceder al clúster con kubectl"

echo "🔍 Verificando instalación de Helm..."
helm version && echo "✅ Helm instalado" || echo "❌ Helm no está instalado"

echo "🔍 Verificando Argo CD..."
kubectl get pods -n argocd && echo "✅ Argo CD desplegado" || echo "❌ Argo CD no está desplegado correctamente"

echo "🔍 Verificando Crossplane..."
kubectl get pods -n crossplane-system && echo "✅ Crossplane desplegado" || echo "❌ Crossplane no está desplegado correctamente"

echo "🔍 Verificando servicio de port-forward..."
systemctl status argocd-portforward.service | grep -q running && echo "✅ Servicio de port-forward activo" || echo "❌ Servicio de port-forward no está activo"

echo "🔍 Verificando puertos abiertos..."
sudo ss -tuln | grep -E ':8080|:8443' && echo "✅ Puertos 8080/8443 abiertos" || echo "❌ Puertos 8080/8443 no están abiertos"

echo "Contraseña de Argo CD:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
EOF

chmod +x /home/ec2-user/verificar_instalacion.sh
chown ec2-user:ec2-user /home/ec2-user/verificar_instalacion.sh
              