resource "aws_amplify_app" "this" {
  name         = "${var.project_name}-${var.environment}"
  repository   = var.github_repository
  access_token = var.github_token_for_frontend

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm install
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  enable_auto_branch_creation = true
  enable_branch_auto_build    = true
  enable_branch_auto_deletion = true
  platform                    = "WEB"

  auto_branch_creation_config {
    enable_pull_request_preview = true
    environment_variables = {
      APP_ENVIRONMENT = "develop"
    }
  }

  iam_service_role_arn = aws_iam_role.amplify_role.arn

  # Comment this on the first run, trigger a build of your branch, 
  #   This will added automatically on the console after deployment. 
  # Add it here to ensure your subsequent terraform runs don't break your amplify deployment.

#   custom_rule {
#     source = "/<*>"
#     status = "200"
#     target = "https://xxx.cloudfront.net/<*>"
#   }

  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# map git branches to amplify
#- - - - - - - - - - - - - - -- - - -- - - - - -- - - - - - -
resource "aws_amplify_branch" "develop" {
  app_id      = aws_amplify_app.this.id
  branch_name = "develop"

  enable_auto_build = true

  framework = "Next.js - SSR"
  stage     = "DEVELOPMENT"

  environment_variables = {
    APP_ENVIRONMENT = "develop"
  }
}

resource "aws_amplify_domain_association" "develop" {
  app_id      = aws_amplify_app.this.id
  domain_name = "stg.dgrebb.de"

  # https://stg.dgrebb.de
  sub_domain {
    branch_name = aws_amplify_branch.develop.branch_name
    prefix      = ""
  }

  # https://www.stg.dgrebb.de
  sub_domain {
    branch_name = aws_amplify_branch.develop.branch_name
    prefix      = "www"
  }
}