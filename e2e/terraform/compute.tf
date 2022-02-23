locals {
  ami_prefix = "nomad-e2e-v2"
}

resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu_bionic_amd64.image_id
  instance_type          = var.instance_type
  key_name               = module.keys.key_name
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.server_count
  iam_instance_profile   = data.aws_iam_instance_profile.nomad_e2e_cluster.name
  availability_zone      = var.availability_zone

  # Instance tags
  tags = {
    Name           = "${local.random_name}-server-${count.index}"
    ConsulAutoJoin = "auto-join-${local.random_name}"
    SHA            = var.nomad_sha
    User           = data.aws_caller_identity.current.arn
    yor_trace      = "b31e7e6d-4eba-430f-a70c-dd57f0db28bd"
  }
}

resource "aws_instance" "client_ubuntu_bionic_amd64" {
  ami                    = data.aws_ami.ubuntu_bionic_amd64.image_id
  instance_type          = var.instance_type
  key_name               = module.keys.key_name
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.client_count_ubuntu_bionic_amd64
  iam_instance_profile   = data.aws_iam_instance_profile.nomad_e2e_cluster.name
  availability_zone      = var.availability_zone

  # Instance tags
  tags = {
    Name           = "${local.random_name}-client-ubuntu-bionic-amd64-${count.index}"
    ConsulAutoJoin = "auto-join-${local.random_name}"
    SHA            = var.nomad_sha
    User           = data.aws_caller_identity.current.arn
    yor_trace      = "4f72bc57-20f5-4de8-a1ca-975c2401c210"
  }
}

resource "aws_instance" "client_windows_2016_amd64" {
  ami                    = data.aws_ami.windows_2016_amd64.image_id
  instance_type          = var.instance_type
  key_name               = module.keys.key_name
  vpc_security_group_ids = [aws_security_group.primary.id]
  count                  = var.client_count_windows_2016_amd64
  iam_instance_profile   = data.aws_iam_instance_profile.nomad_e2e_cluster.name
  availability_zone      = var.availability_zone

  user_data = file("${path.root}/userdata/windows-2016.ps1")

  # Instance tags
  tags = {
    Name           = "${local.random_name}-client-windows-2016-${count.index}"
    ConsulAutoJoin = "auto-join-${local.random_name}"
    SHA            = var.nomad_sha
    User           = data.aws_caller_identity.current.arn
    yor_trace      = "e7843989-e8d3-4bff-8ec3-752d03f32668"
  }
}

data "external" "packer_sha" {
  program = ["/bin/sh", "-c", <<EOT
sha=$(git log -n 1 --pretty=format:%H packer)
echo "{\"sha\":\"$${sha}\"}"
EOT
  ]

}

data "aws_ami" "ubuntu_bionic_amd64" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${local.ami_prefix}-ubuntu-bionic-amd64-*"]
  }

  filter {
    name   = "tag:OS"
    values = ["Ubuntu"]
  }

  filter {
    name   = "tag:BuilderSha"
    values = [data.external.packer_sha.result["sha"]]
  }
}

data "aws_ami" "windows_2016_amd64" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${local.ami_prefix}-windows-2016-amd64-*"]
  }

  filter {
    name   = "tag:OS"
    values = ["Windows2016"]
  }

  filter {
    name   = "tag:BuilderSha"
    values = [data.external.packer_sha.result["sha"]]
  }
}
