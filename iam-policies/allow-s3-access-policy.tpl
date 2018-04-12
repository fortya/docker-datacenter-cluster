{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPutReadAndGet",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject*",
                "s3:ReadObject*",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${S3_CONFIGURATIONS_BUCKET_NAME}/*"
            ]
        },
        {
            "Sid": "AllowBucketGeneralAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketAcl",
                "s3:List*"
            ],
            "Resource": "arn:aws:s3:::${S3_CONFIGURATIONS_BUCKET_NAME}"
        }
    ]
}
