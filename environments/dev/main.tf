# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "functions" {
  type = map(object({
    name        = string
    description = string
    runtime     = string
    entry_point = string
    source_file  = string
    filename = string
    env_vars    = map(string)
  }))
  default = {
    function0 = {
      name        = "hello-world"
      description = "a_sample_function"
      runtime     = "python311"
      entry_point = "hello_world"
      source_file  = "src/hello_world"
      filename = "main.py"
      env_vars = {
        "FUNCTION_SPECIFIC_ENVS_HERE" = "",
      }
    }
    

    # Add more functions as needed
  }
}

locals {
  env = "main"
}

provider "google" {
  project = "${var.project}"
}

module "vpc" {
  source  = "../../modules/vpc"
  project = "${var.project}"
  env     = "${local.env}"
}

module "http_server" {
  source  = "../../modules/http_server"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
}

module "firewall" {
  source  = "../../modules/firewall"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
}


terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.34.0"
    }
  }
}



resource "random_id" "default" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name                        = "${random_id.default.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "function_zip" {
  for_each    = var.functions
  type        = "zip"
  source_dir = "${path.module}/../../${each.value.source_file}" #change this to source_dir
  output_path = "/tmp/${each.key}.zip"
  output_file_mode = "0666"
}
resource "google_storage_bucket_object" "object" {
  for_each = var.functions
  name     = "${each.key}.zip"
  bucket   = google_storage_bucket.default.name
  source   = data.archive_file.function_zip[each.key].output_path
}

resource "google_cloudfunctions2_function" "default" {
  for_each    = var.functions
  name        = each.value.name
  location    = "us-central1"
  description = each.value.description

  build_config {
    runtime     = each.value.runtime
    entry_point = each.value.entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.default.name
        object = google_storage_bucket_object.object[each.key].name
      }
    }
    environment_variables = merge(
      {
        GOOGLE_FUNCTION_SOURCE = each.value.filename
      },
      each.value.env_vars
    )
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 540
  }
}


output "cloud_run_service_names" {
  value = {
    for k, v in google_cloudfunctions2_function.default : k => v.service_config[0].service
  }
}

resource "google_cloud_run_service_iam_member" "member" {
  for_each = var.functions
  location = google_cloudfunctions2_function.default[each.key].location
  service  = google_cloudfunctions2_function.default[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"

  depends_on = [google_cloudfunctions2_function.default]
}

output "function_uris" {
  value = {
    for k, v in google_cloudfunctions2_function.default : k => v.service_config[0].uri
  }
}