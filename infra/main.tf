provider "google" {
  project = "{{upskill-ai-app}}"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_cloudfunctions_function" "default" {

    
  name        = "function-test"
  description = "My function"
  runtime     = "nodejs14"
  available_memory_mb = 256

  source_archive_bucket = "<BUCKET_NAME>"
  source_archive_object = "<OBJECT_NAME>"

  trigger_http = true
  entry_point  = "yourFunctionEntryPoint"

  project = "PROJECT_ID"
  region  = "us-central1"
} 