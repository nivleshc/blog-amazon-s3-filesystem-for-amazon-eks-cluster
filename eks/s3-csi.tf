resource "aws_iam_role" "s3_csi" {
  name = "${var.eks.cluster_name}-s3-csi-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${basename(local.oidc_url)}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${basename(local.oidc_url)}:sub" : "system:serviceaccount:kube-system:s3-csi-*",
            "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${basename(local.oidc_url)}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_csi_bucket_policy" {
  name        = "${var.eks.cluster_name}-s3-csi-bucket-policy"
  path        = "/"
  description = "IAM Policy used by Mountpoint for Amazon S3 CSI Driver for ${var.eks.cluster_name} cluster"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "MountpointFullBucketAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.eks.s3_csi_bucket_name}"
        ]
      },
      {
        "Sid" : "MountpointFullObjectAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.eks.s3_csi_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_csi" {
  policy_arn = aws_iam_policy.s3_csi_bucket_policy.arn
  role       = aws_iam_role.s3_csi.name
}

resource "aws_eks_addon" "s3_csi" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "aws-mountpoint-s3-csi-driver"
  addon_version               = data.aws_eks_addon_version.s3_csi.version
  service_account_role_arn    = aws_iam_role.s3_csi.arn
  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Name = "${var.eks.cluster_name}-aws-mountpoint-s3-csi-driver"
  }

  lifecycle {
    ignore_changes = [ 
      addon_version
    ]
  }
}
