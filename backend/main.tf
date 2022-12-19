variable "replicas_count" {
  description = "How many replicas to run"
}

variable "ns_backend" {
  description = "Namespace name of the dpeloyment"
}

resource "kubernetes_namespace" "ns_backend" {
  metadata {
    name = var.ns_backend
  }
}

resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend"
    namespace = kubernetes_namespace.ns_backend.metadata.0.name
  }

  spec {
    replicas = var.replicas_count
    selector {
      match_labels = {
        app = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }
      spec {
        container {
          image = "ovrchan/backend-example:v2"
          name  = "backend"

          port {
            container_port = 8090
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "backend"
    namespace = kubernetes_namespace.ns_backend.metadata.0.name
  }
  spec {
    selector = {
      "app" = kubernetes_deployment.backend.spec.0.template.0.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 8090
    }
  }
}