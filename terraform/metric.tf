resource "google_monitoring_custom_service" "cloud_run" {
  service_id   = "cloud-run"
  display_name = "SLO related to Cloud Run"
}

resource "google_monitoring_slo" "http_status_rate_200_slo" {
  service      = google_monitoring_custom_service.cloud_run.service_id
  slo_id       = "http-status-rate-200"
  display_name = "HTTP Status Rate (200)"

  goal                = 0.999
  rolling_period_days = 3

  request_based_sli {
    good_total_ratio {
      good_service_filter = join(" AND ", [
        "metric.type=\"run.googleapis.com/request_count\"",
        "resource.type=\"cloud_run_revision\"",
        "resource.label.\"service_name\"=\"go-boiler-api\"",
        "metric.label.\"response_code\"=\"200\""
      ])
      total_service_filter = join(" AND ", [
        "metric.type=\"run.googleapis.com/request_count\"",
        "resource.type=\"cloud_run_revision\"",
        "resource.label.\"service_name\"=\"go-boiler-api\"",
      ])
    }
  }
}
