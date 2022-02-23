# Nomad ECS Remote Task Driver E2E
resource "aws_ecs_cluster" "nomad_rtd_e2e" {
  name = "nomad-rtd-e2e"
  tags = {
    yor_trace = "8fb65e3b-193e-44cf-b185-7edb07e4dc00"
  }
}

resource "aws_ecs_task_definition" "nomad_rtd_e2e" {
  family                = "nomad-rtd-e2e"
  container_definitions = file("ecs-task.json")

  # Don't need a network for e2e tests
  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  tags = {
    yor_trace = "a9768e42-a1c4-4f85-af74-2a5f972a2f01"
  }
}

data "template_file" "ecs_vars_hcl" {
  template = <<EOT
security_groups = ["${aws_security_group.primary.id}"]
subnets         = ["${data.aws_subnet.default.id}"]
EOT
}

resource "local_file" "ecs_vars_hcl" {
  content         = data.template_file.ecs_vars_hcl.rendered
  filename        = "${path.module}/../remotetasks/input/ecs.vars"
  file_permission = "0664"
}
