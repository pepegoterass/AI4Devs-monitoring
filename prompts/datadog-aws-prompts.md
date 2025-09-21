# Datadog-AWS Integration Prompts Documentation

Este documento contiene todos los prompts utilizados para generar el código Terraform relacionado con la integración Datadog-AWS para el proyecto LTI.

## 📋 Tabla de Contenidos

1. [Configuración del Proveedor Datadog](#configuración-del-proveedor-datadog)
2. [Integración AWS-Datadog](#integración-aws-datadog)
3. [Scripts de User Data](#scripts-de-user-data)
4. [Dashboard y Monitoreo](#dashboard-y-monitoreo)
5. [Variables y Configuración](#variables-y-configuración)

---

## 🔧 Configuración del Proveedor Datadog

### Prompt Utilizado:
```
Create a Terraform provider configuration for Datadog integration with the following requirements:
- Add required_providers block with AWS and Datadog providers
- Configure AWS provider with region variable
- Configure Datadog provider with API key, app key, and API URL variables
- Use latest stable versions of both providers
- Make credentials configurable through variables for security
```

### Código Generado:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.39"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}
```

---

## 🔗 Integración AWS-Datadog

### Prompt Utilizado:
```
Generate comprehensive Terraform code for AWS-Datadog integration with the following specifications:

1. Create IAM role for Datadog with proper trust policy including:
   - Datadog AWS account ID (464622532012)
   - External ID condition for security
   - Assume role permissions

2. Create IAM policy with all necessary permissions for Datadog monitoring including:
   - CloudWatch metrics and logs access
   - EC2, RDS, S3, Lambda monitoring permissions
   - Auto Scaling, ELB, and other AWS services
   - Security and compliance monitoring capabilities

3. Create Datadog integration resource that:
   - Links the AWS account with Datadog
   - Configures host tags and filter tags
   - Sets up account-specific namespace rules

4. Include proper dependencies and tagging strategy
```

### Código Generado:
El código incluye:
- `aws_iam_role.datadog_integration_role` con trust policy
- `aws_iam_role_policy.datadog_integration_policy` con permisos completos
- `datadog_integration_aws.main` para la integración
- Data source para obtener account ID
- Outputs para información importante

---

## 📊 Dashboard y Monitoreo

### Prompt Utilizado:
```
Create a comprehensive Datadog dashboard using Terraform for AWS infrastructure monitoring with:

1. Dashboard configuration:
   - Title: "LTI AWS Infrastructure Monitoring"
   - Description explaining the purpose
   - Ordered layout type

2. Widgets for monitoring:
   - EC2 CPU utilization timeseries
   - Memory utilization timeseries
   - Network In/Out metrics
   - Disk I/O operations
   - Total EC2 instances count
   - Top EC2 instances by CPU usage

3. Monitoring alerts:
   - High CPU usage alert (>80% critical, >70% warning)
   - High memory usage alert (<15% available critical, <20% warning)
   - Proper notification channels and timeouts

4. Apply consistent tagging strategy for all resources
```

### Código Generado:
- Dashboard completo con 6 widgets diferentes
- 2 monitores de alertas críticas
- Configuración de umbrales y notificaciones
- Tags consistentes para organización

---

## 🖥️ Scripts de User Data

### Prompt Utilizado:
```
Modify the existing EC2 user data scripts to install and configure Datadog agent with:

1. Agent installation:
   - Use official Datadog installation script
   - Configure with API key variable
   - Set proper site (datadoghq.com)

2. Agent configuration:
   - Enable logs collection
   - Enable process monitoring
   - Enable APM for application tracing
   - Set environment tags (production)
   - Set service-specific tags

3. Docker integration:
   - Configure Docker monitoring
   - Enable container metrics collection
   - Set up log collection from containers
   - Configure autodiscovery labels

4. Service-specific configurations:
   - Backend: Node.js monitoring
   - Frontend: Nginx monitoring and JavaScript logs
   - Proper labeling for container autodiscovery

5. Ensure agent starts automatically and survives reboots
```

### Código Generado:
Scripts actualizados para backend y frontend con:
- Instalación automática del agente Datadog
- Configuración completa en `/etc/datadog-agent/datadog.yaml`
- Integración con Docker
- Labels para autodiscovery
- Configuraciones específicas por servicio

---

## 📋 Variables y Configuración

### Prompt Utilizado:
```
Create a comprehensive variables.tf file for the Datadog-AWS integration with:

1. AWS variables:
   - Region with default
   - Instance type configuration
   - Key pair name

2. Datadog variables:
   - API key (sensitive)
   - Application key (sensitive)
   - API URL with default
   - External ID for integration

3. All variables should include:
   - Proper descriptions
   - Type specifications
   - Default values where appropriate
   - Sensitive flag for credentials
```

### Código Generado:
```hcl
# AWS Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Datadog Variables
variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true
}
# ... etc
```

---

## 🚀 Instrucciones de Uso

### 1. Configuración de Variables
Crear un archivo `terraform.tfvars`:
```hcl
datadog_api_key = "tu_api_key_aqui"
datadog_app_key = "tu_app_key_aqui"
aws_region = "us-east-1"
```

### 2. Inicialización y Aplicación
```bash
terraform init
terraform plan
terraform apply
```

### 3. Verificación
- Verificar en Datadog console que la integración aparece
- Confirmar que el dashboard muestra métricas
- Validar que las alertas están configuradas

---

## 🔍 Patrones de Prompt Engineering Utilizados

1. **Especificidad Técnica**: Prompts detallados con requisitos técnicos específicos
2. **Estructura Modular**: Separación de responsabilidades en prompts diferentes
3. **Mejores Prácticas**: Inclusión de seguridad, tags, y configuraciones enterprise
4. **Contexto Completo**: Proporcionando contexto del proyecto LTI y arquitectura existente
5. **Validación**: Prompts que incluyen verificación y testing

---

## 📝 Notas Importantes

- Todos los prompts fueron diseñados para generar código production-ready
- Se incluyeron consideraciones de seguridad en cada prompt
- Los prompts siguieron las mejores prácticas de Terraform
- Se mantuvo consistencia con la arquitectura existente del proyecto

---

*Documentado por: Sistema de IA*  
*Fecha: 21 de Septiembre, 2025*  
*Proyecto: LTI AWS Infrastructure Monitoring*