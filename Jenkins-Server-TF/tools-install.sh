#!/bin/bash
set -euo pipefail

# For Ubuntu 22.04

# Base packages
sudo apt update
sudo apt install -y ca-certificates curl wget gnupg unzip fontconfig software-properties-common lsb-release

# Install Java 21
sudo apt install -y openjdk-21-jre
java --version

# Install Jenkins
sudo install -m 0755 -d /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu

# Run SonarQube container
sudo docker run -d --name sonarqube --restart unless-stopped -p 9000:9000 sonarqube:community

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

sudo apt update
sudo apt install -y terraform
terraform version

# Installing Kubectl
curl -LO https://dl.k8s.io/release/v1.33.5/bin/linux/amd64/kubectl
curl -LO https://dl.k8s.io/release/v1.33.5/bin/linux/amd64/kubectl.sha256
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install --update
aws --version

# Install Trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null

sudo apt update
sudo apt install -y trivy
trivy --version