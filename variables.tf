variable "api_key" {
    description = "The New Relic API key"
}
variable "account_id" {
    description = "Your New Relic Account Id"
}
variable "region" {
    description = "US or EU"
    default = "US"
}
/*variable "name" {
    description = "The name of the entity in New Relic One. The first entity matching this name for the given search parameters will be returned."
} 
variable "domain" {
    description = "The entity's domain. Valid values are APM, BROWSER, INFRA, MOBILE, SYNTH, and VIZ. If not specified, all domains are searched."
}
variable "type" {
    description = "The entity's type. Valid values are APPLICATION, DASHBOARD, HOST, MONITOR, and WORKLOAD."
}
/*

/* variable "tag" {
    description = "A tag applied to the entity."
    type = string
} */

/*
variable "slack_url" {
    description = "New Relic slack integration webhook url"
} */

variable "channel_id" {
    description = "New Relic alert channel id"
  }