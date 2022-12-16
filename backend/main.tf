variable "replicas_count" {
  description = "How many replicas to run"
}

resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend"
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