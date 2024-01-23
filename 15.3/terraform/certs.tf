resource "yandex_cm_certificate" "serwalk-cert" {
  name    = "serwalk-cert"
  domains = ["www.icebucket.com.website.yandexcloud.net"]

  self_managed {
    certificate = "cert/cert.pem"
private_key_lockbox_secret {
      id  = yandex_lockbox_secret.my_secret.id
      key = yandex_lockbox_secret_version.my_secret.entries[0].key
    }
  }
#    private_key = "cert/key.pem"
#  }
}

resource "yandex_kms_symmetric_key" "key-walk" {
  name              = "key-walk"
  description       = "symmetric key for bucket"
  default_algorithm = "AES_256"
}

resource "yandex_lockbox_secret" "my_secret" {
  name                = "my_secret"
  description         = "my_secret"
  folder_id           = "b1g709q14ibltvag3ekd"
  kms_key_id          =  yandex_kms_symmetric_key.key-walk.id
  deletion_protection = false
}

resource "yandex_lockbox_secret_version" "my_secret" {
  secret_id = yandex_lockbox_secret.my_secret.id
  entries {
    key        = "cert_key"
    text_value = <<-EOT
-----BEGIN PRIVATE KEY-----
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
OHIo7KNgl/gl8kDv/7n0UsolMvRL7Vw=
-----END PRIVATE KEY-----
EOT 
  }
}
