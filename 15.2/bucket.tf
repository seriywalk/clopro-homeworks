// Create service account for bucket
resource "yandex_iam_service_account" "sa_bucket" {
  name        = "sa4bucket"
  description = "For lesson 15.2"
  folder_id   = var.yc_folder_id
}

// Assigning a role on resource
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id   = var.yc_folder_id
  role        = "editor"
  member      = "serviceAccount:${yandex_iam_service_account.sa_bucket.id}"
}

// Create Static Access Key
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
 service_account_id = yandex_iam_service_account.sa_bucket.id
 description        = "static access key for object storage"
# pgp_key            = "keybase:keybaseusername"
 }

// Create bucket with key
resource "yandex_storage_bucket" "bucket_net" {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = "seriywalk-bucket"
    acl    = "public-read"
}

// Place image to bucket
resource "yandex_storage_object" "image" {
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    bucket = yandex_storage_bucket.bucket_net.bucket
    key    = "icebucket.png"
    source = "./icebucket.png"
    acl    = "public-read"
}
