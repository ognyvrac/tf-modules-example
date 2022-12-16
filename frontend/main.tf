variable "replicas_count" {
  description = "How many replicas to deploy"
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
  }

  spec {
    replicas = var.replicas_count
    selector {
      match_labels = {
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }
      spec {
        container {
          image = "ovrchan/frontend-example:v2"
          name  = "frontend"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
  }
  spec {
    selector = {
      "app" = kubernetes_deployment.frontend.spec.0.template.0.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "frontend" {
  metadata {
    name = "frontend"
  }
  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service.frontend.metadata.0.name
              port {
                number = kubernetes_service.frontend.spec.0.port.0.port
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}