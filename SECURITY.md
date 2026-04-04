# 🔐 Consideraciones de seguridad

Este documento describe las decisiones de seguridad aplicadas en este proyecto, en particular con respecto al **cifrado en reposo** para los servicios de mensajería de AWS.

Este repositorio está destinado a fines **educativos y demostrativos** y muestra las prácticas de seguridad recomendadas sin añadir complejidad operativa innecesaria.

---

## 🔒 Cifrado en reposo

Este proyecto habilita el cifrado en reposo para **Amazon SNS** y **Amazon SQS**, utilizando los mecanismos predeterminados y recomendados proporcionados por AWS.

---

### 🔹 Cifrado de Amazon SNS

Amazon SNS está configurado para usar el **cifrado KMS administrado por AWS**.

- **Clave KMS utilizada:** `alias/aws/sns`
- Totalmente administrada y rotada por AWS
- No se requiere administración de claves por parte del cliente

Este enfoque garantiza un cifrado seguro en reposo, manteniendo la configuración simple y fácil de entender para fines de aprendizaje.

---

### 🔹 Cifrado de Amazon SQS

Amazon SQS utiliza **cifrado administrado por el servicio (SSE-SQS)**.

- El servicio SQS gestiona completamente el cifrado.
- No se requiere configuración explícita de claves KMS.
- AWS gestiona el almacenamiento, la disponibilidad y la rotación de claves.

Este es un enfoque común y recomendado cuando no se requiere un control de claves detallado.

---

## 🧠 ¿Por qué diferentes modelos de cifrado?

SNS y SQS implementan el cifrado de forma diferente por diseño.

Este proyecto utiliza intencionadamente el **enfoque de cifrado predeterminado y recomendado para cada servicio** para:

- Garantizar que los datos estén cifrados en reposo.

- Reducir la sobrecarga operativa.

- Mantener una arquitectura fácil de entender.

- Cumplir con las mejores prácticas de AWS.

---

## ⚠️ Notas importantes

- Este repositorio está destinado únicamente a fines **educativos**.

- **No está listo para producción** sin reforzar la seguridad. - Para cargas de trabajo de producción, considere:

- Usar **claves KMS administradas por el cliente (CMK)**

- Restringir el uso de claves mediante políticas de IAM

- Habilitar la monitorización y la auditoría (CloudTrail, CloudWatch)

- Aplicar controles de acceso de mínimo privilegio

---

## ✅ Resumen

| Servicio | Tipo de cifrado | Administración de claves |
|-------|-----------------|----------------|
| Amazon SNS | SSE with AWS-managed KMS key | AWS |
| Amazon SQS | SSE-SQS (service-managed) | AWS |

---

Este modelo de seguridad ofrece un **enfoque equilibrado entre protección, simplicidad y claridad**, lo que lo hace ideal para escenarios de aprendizaje y demostración.