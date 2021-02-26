terraform {
  # Require Terraform version 0.13.x (recommended)
  required_version = "~> 0.14.0"

  # Require the latest 2.x version of the New Relic provider
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.12"
    }
  }
}

provider "newrelic" {
  account_id = var.account_id 
  api_key = var.api_key 
  region = var.region        
}

/*
# Define an entity that already exsist in new relic
data "newrelic_entity" "todo_app" {
  name = "flask-todo-app"
  domain = var.domain 
  type = var.type
} 
*/

/*
#Use this resource to create, update, and delete tags for a New Relic One entity.
resource "newrelic_entity_tags" "foo" {
    guid = data.newrelic_entity.foo.guid

    tag {
        key = "my-key"
        values = ["my-value", "my-other-value"]
    }

    tag {
        key = "my-key-2"
        values = ["my-value-2"]
    }
}
*/


/*# Create an alert policy
resource "newrelic_alert_policy" "golden_signal_policy" {
  name = "Golden Signals - ${data.newrelic_entity.todo_app.name}"
} */

# Create an alert policy
resource "newrelic_alert_policy" "golden_signal_policy" {
  name = "Golden Signals"
}


/*
# Use an existing alert policy
data "newrelic_alert_channel" "ExistingPolicy" {
    name = "Preexisting Policy"
}

resource "newrelic_alert_policy_channel" "foo" {
  policy_id  = data.newrelic_alert_policy.foo.id
  channel_id = data.newrelic_alert_channel.foo.id
}
*/

/*
# Response time
resource "newrelic_alert_condition" "response_time_web" {
  policy_id       = newrelic_alert_policy.golden_signal_policy.id
  name            = "High Response Time (Web) - ${data.newrelic_entity.todo_app.name}"
  type            = "apm_app_metric"
  entities        = [data.newrelic_entity.todo_app.application_id]
  metric          = "response_time_web"
  condition_scope = "application"

  term {
    duration      = 5
    operator      = "above"
    priority      = "critical"
    threshold     = "5"
    time_function = "all"
  }
}
*/

/*
# Low throughput
resource "newrelic_alert_condition" "throughput_web" {
  policy_id       = newrelic_alert_policy.golden_signal_policy.id
  name            = "High Throughput (Web)"
  type            = "apm_app_metric"
  entities        = [data.newrelic_entity.todo_app.application_id]
  metric          = "throughput_web"
  condition_scope = "application"

  # Define a critical alert threshold that will
  # trigger after 5 minutes above 10 requests per minute.
  term {
    priority      = "critical"
    duration      = 5
    operator      = "above"
    threshold     = "10"
    time_function = "all"
  }
}
*/

/*
# Error percentage
resource "newrelic_alert_condition" "error_percentage" {
  policy_id       = newrelic_alert_policy.golden_signal_policy.id
  name            = "High Error Percentage"
  type            = "apm_app_metric"
  entities        = [data.newrelic_entity.todo_app.application_id]
  metric          = "error_percentage"
  condition_scope = "application"

  # Define a critical alert threshold that will trigger after 5 minutes above a 10% error rate.
  term {
    duration      = 5
    operator      = "above"
    threshold     = "10"
    time_function = "all"
  }
}
*/

# High CPU usage
resource "newrelic_infra_alert_condition" "high_cpu" {
  policy_id   = newrelic_alert_policy.golden_signal_policy.id
  name        = "High CPU usage"
  type        = "infra_metric"
  event       = "SystemSample"
  select      = "cpuPercent"
  comparison  = "above"
  where       = "(owner = 'tab')"

  # Define a critical alert threshold
  critical {
    duration      = 60
    value         = 95
    time_function = "all"
  }
}

# High Memory usage
resource "newrelic_infra_alert_condition" "high_mem" {
  policy_id   = newrelic_alert_policy.golden_signal_policy.id
  name        = "Low Memory available"
  type        = "infra_metric"
  event       = "SystemSample"
  select      = "memoryFreePercent"
  comparison  = "below"
  where       = "(owner = 'tab')"

  # Define a critical alert threshold
  critical {
    duration      = 30
    value         = 10
    time_function = "all"
  }
}

#High CPU usage with nrql
resource "newrelic_nrql_alert_condition" "high_cpu_usage" {
  policy_id                    = newrelic_alert_policy.golden_signal_policy.id
  type                         = "static"
  name                         = "High CPU usage"
  description                  = "Alert when CPU above 95%"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option          = "static"
  fill_value           = 1.0

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = true
  close_violations_on_expiration = true

  nrql {
    query             = "SELECT average(cpuPercent) FROM SystemSample WHERE owner = 'tab' facet hostname"
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 95
    threshold_duration    = 3600
    threshold_occurrences = "ALL"
  }
}

#High Memory usage with nrql
resource "newrelic_nrql_alert_condition" "high_mem_usage" {
  policy_id                    = newrelic_alert_policy.golden_signal_policy.id
  type                         = "static"
  name                         = "High Memory usage"
  description                  = "Alert when memory usage exceeds 90%"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option          = "static"
  fill_value           = 1.0

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = true
  close_violations_on_expiration = true

  nrql {
    query             = "SELECT average(memoryUsedPercent) FROM SystemSample WHERE owner = 'tab' facet hostname"
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 1800
    threshold_occurrences = "ALL"
  }
}

#High Disk Space Usage
resource "newrelic_nrql_alert_condition" "high_disk_usage" {
  policy_id                    = newrelic_alert_policy.golden_signal_policy.id
  type                         = "static"
  name                         = "High Disk Space usage"
  description                  = "Alert when disk space usage exceeds 80%"
  enabled                      = true
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option          = "static"
  fill_value           = 1.0

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = true
  close_violations_on_expiration = true

  nrql {
    query             = "SELECT average(diskUsedPercent) FROM SystemSample WHERE owner = 'tab' facet hostname"
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 80
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}

/*
# Slack notification channel
resource "newrelic_alert_channel" "slack_notification" {
  name = "todo-app-slack"
  type = "slack"

  config {
    # Use the URL provided in your New Relic Slack integration
    url     = var.slack_url
    channel = "todo-app"
  }
}

# Subscribe alert policy to notification channel(s)
resource "newrelic_alert_policy_channel" "ChannelSubs" {
  policy_id = newrelic_alert_policy.golden_signal_policy.id
  channel_ids = [
    newrelic_alert_channel.slack_notification.id
  ]
}*/

# Subscribe alert policy to notification channel(s)
resource "newrelic_alert_policy_channel" "ChannelSubs" {
  policy_id = newrelic_alert_policy.golden_signal_policy.id
  channel_ids = [
    var.channel_id
  ]
}
