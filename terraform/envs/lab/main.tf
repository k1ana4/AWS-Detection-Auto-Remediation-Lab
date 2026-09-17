module "logging" {
  source = "../../modules/logging"
}

module "detection" {
  source = "../../modules/detection"
}

module "alerting" {
  source       = "../../modules/alerting"
  alert_emails = var.alert_emails
}
