# Have unique bucket names
resource "random_id" "bucket_id" {
  byte_length = 16
}

# Unique DTR Replica D
resource "random_id" "dtr_replica_id" {
  byte_length = 6
}
